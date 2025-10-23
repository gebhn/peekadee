-- name: GetSpawns :many
SELECT DISTINCT
    nt.name AS npc_name,
    nt.id AS npc_id,
    nt.level,
    nt.race,
    nt.class,
    nt.hp,
    nt.mindmg,
    nt.maxdmg,
    COUNT(s2.id) AS spawn_count
FROM npc_types nt
JOIN spawnentry se ON nt.id = se.npcID
JOIN spawn2 s2 ON se.spawngroupID = s2.spawngroupID
WHERE s2.zone = ?
GROUP BY nt.id, nt.name, nt.level, nt.race, nt.class, nt.hp, nt.mindmg, nt.maxdmg
ORDER BY nt.name ASC;
