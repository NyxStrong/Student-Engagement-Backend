import Fluent
import SQLKit

struct CreatePointView: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let sql = database as! any SQLDatabase
        try await sql.raw("""
            CREATE VIEW user_points_summary AS
            SELECT
                s.userId,
                COUNT(CASE WHEN s.rsvp = TRUE THEN 1 END)                   AS rsvp_total,
                COUNT(CASE WHEN s.attendance = TRUE THEN 1 END)              AS attendance_total,
                COALESCE(SUM(s.participation), 0)                            AS participation_total,
                COUNT(CASE WHEN s.rating IS NOT NULL THEN 1 END)        AS feedback_total,
                (
                    COUNT(CASE WHEN s.rsvp = TRUE THEN 1 END)          * 1  +
                    COUNT(CASE WHEN s.attendance = TRUE THEN 1 END)     * 5  +
                    COALESCE(SUM(s.participation), 0)                        +
                    COUNT(CASE WHEN s.rating IS NOT NULL THEN 1 END) * 4
                )                                                            AS calculated_points
            FROM signups s
            GROUP BY s.userId
            """).run()

        // Trigger on INSERT into signups
        try await sql.raw("""
            CREATE TRIGGER IF NOT EXISTS sync_user_points_after_insert
            AFTER INSERT ON signups
            FOR EACH ROW
            BEGIN
                UPDATE users
                SET points = COALESCE((
                    SELECT
                        ups.calculated_points
                    FROM user_points_summary ups
                    WHERE ups.userId = NEW.userId
                ), 0)
                WHERE id = NEW.userId;
            END
            """).run()
 
        // Trigger on UPDATE of signups
        try await sql.raw("""
            CREATE TRIGGER IF NOT EXISTS sync_user_points_after_update
            AFTER UPDATE ON signups
            FOR EACH ROW
            BEGIN
                UPDATE users
                SET points = COALESCE((
                    SELECT
                        ups.calculated_points
                    FROM user_points_summary ups
                    WHERE ups.userId = NEW.userId
                ), 0)
                WHERE id = NEW.userId;
            END
            """).run()
 
        // Trigger on DELETE from signups (recalculate in case a row is removed)
        try await sql.raw("""
            CREATE TRIGGER IF NOT EXISTS sync_user_points_after_delete
            AFTER DELETE ON signups
            FOR EACH ROW
            BEGIN
                UPDATE users
                SET points = COALESCE((
                    SELECT
                        ups.calculated_points
                    FROM user_points_summary ups
                    WHERE ups.userId = OLD.userId
                ), 0)
                WHERE id = OLD.userId;
            END
            """).run()
    }
 
    func revert(on database: any Database) async throws {
        let sql = database as! any SQLDatabase
        try await sql.raw("DROP TRIGGER IF EXISTS sync_user_points_after_insert").run()
        try await sql.raw("DROP TRIGGER IF EXISTS sync_user_points_after_update").run()
        try await sql.raw("DROP TRIGGER IF EXISTS sync_user_points_after_delete").run()
        try await sql.raw("DROP VIEW IF EXISTS user_points_summary").run()

    }
}
