-- name: GetNPCsWhichDropsItemByID :many
SELECT 
    npc_types.id,
    npc_types.name
FROM npc_types
LEFT JOIN spawnentry 
    ON npc_types.id = spawnentry.npcID
LEFT JOIN spawn2 
    ON spawnentry.spawngroupID = spawn2.spawngroupID
LEFT JOIN loottable_entries 
    ON npc_types.loottable_id = loottable_entries.loottable_id
LEFT JOIN lootdrop_entries 
    ON loottable_entries.lootdrop_id = lootdrop_entries.lootdrop_id
WHERE lootdrop_entries.item_id = ?
GROUP BY npc_types.id;
