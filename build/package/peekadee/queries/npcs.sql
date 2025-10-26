-- name: SearchNPCsByName :many
-- Search NPCs by partial name match
SELECT 
    id,
    name,
    level,
    race,
    class,
    hp,
    mindmg,
    maxdmg
FROM npc_types
WHERE name LIKE ?
ORDER BY name;

-- name: GetNPCLootTable :one
-- Get loot table info for an NPC
SELECT 
    lt.id as loottable_id
FROM npc_types nt
JOIN loottable lt ON nt.loottable_id = lt.id
WHERE nt.id = ?;
