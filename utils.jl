
function rm_count(deck)
    r = 0
    m = 0
    for elem in deck
        if elem.prints[1].rarity == 3
            r += elem.amount
        elseif elem.prints[1].rarity == 4
            m += elem.amount
        end
    end
    (r = r, m = m)
end
