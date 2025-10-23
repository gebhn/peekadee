-- name: GetDroppedBy :many
SELECT 
    nt.id, 
    nt.name, 
    nt.level, 
    le.chance, 
    le.item_charges
FROM items i
JOIN lootdrop_entries le ON i.id = le.item_id
JOIN lootdrop ld ON le.lootdrop_id = ld.id
JOIN loottable_entries lte ON ld.id = lte.lootdrop_id
JOIN loottable lt ON lte.loottable_id = lt.id
JOIN npc_types nt ON lt.id = nt.loottable_id
WHERE i.name LIKE ?
ORDER BY le.chance DESC;

-- name: GetSoldBy :many
SELECT 
	nt.id,
	nt.name,
	nt.level,
	ml.slot,
	i.price
FROM items i
JOIN merchantlist ml ON i.id = ml.item
JOIN npc_types nt ON ml.merchantid = nt.merchant_id
WHERE i.Name LIKE ?
ORDER BY i.price;
