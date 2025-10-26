-- name: GetLootTableDrops :many
-- Get all loot drops for a loot table
SELECT 
    ld.id AS lootdrop_id,
    ld.name AS lootdrop_name,
    lte.multiplier,
    lte.probability,
    lte.droplimit,
    lte.mindrop
FROM loottable_entries lte
JOIN lootdrop ld ON lte.lootdrop_id = ld.id
WHERE lte.loottable_id = ?
ORDER BY lte.probability DESC;

-- name: GetLootDropItems :many
-- Get all items in a loot drop
SELECT 
    i.id AS item_id,
    i.Name AS item_name,
    le.chance,
    le.item_charges,
    le.equip_item,
    le.minlevel,
    le.maxlevel,
    le.multiplier,
    i.price,
    i.icon
FROM lootdrop_entries le
JOIN items i ON le.item_id = i.id
WHERE le.lootdrop_id = ?
ORDER BY le.chance DESC;
