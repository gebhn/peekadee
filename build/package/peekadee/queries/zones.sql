-- name: GetNPCsByZone :many
SELECT DISTINCT
    nt.name AS npc_name,
    nt.id AS npc_id,
    nt.level,
    nt.race,
    nt.class,
    nt.hp,
    nt.mindmg,
    nt.maxdmg,
    sg.id AS spawngroup_id,
    sg.name AS spawngroup_name,
    COUNT(DISTINCT s2.id) AS spawn_count
FROM npc_types nt
JOIN spawnentry se ON nt.id = se.npcID
JOIN spawngroup sg ON se.spawngroupID = sg.id
JOIN spawn2 s2 ON sg.id = s2.spawngroupID
WHERE s2.zone IS NOT NULL AND s2.zone = ?
GROUP BY nt.id, nt.name, nt.level, nt.race, nt.class, nt.hp, nt.mindmg, nt.maxdmg, sg.id, sg.name
ORDER BY nt.name ASC;

-- name: GetZones :many
SELECT COALESCE(short_name, '') AS short_name, long_name 
FROM zone 
WHERE short_name IS NOT NULL
ORDER BY short_name;
