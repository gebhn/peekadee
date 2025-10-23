-- name: GetLoot :many
SELECT 
    nt.name AS npc_name, 
    i.name AS item_name, 
    le.chance, 
    le.item_charges, 
    i.price
FROM npc_types nt
JOIN loottable lt ON nt.loottable_id = lt.id
JOIN loottable_entries lte ON lt.id = lte.loottable_id
JOIN lootdrop ld ON lte.lootdrop_id = ld.id
JOIN lootdrop_entries le ON ld.id = le.lootdrop_id
JOIN items i ON le.item_id = i.id
WHERE nt.name LIKE ?
ORDER BY le.chance DESC;
