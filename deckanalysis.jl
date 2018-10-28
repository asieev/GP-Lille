using ArenaSim
using Statistics

include("utils.jl")

files = readdir("decks/top8")

decks = ArenaSim.deckreader_mtgo_format.( joinpath.("decks/top8", files), 
	strip_sideboard = false)

decks = deckinfo.(decks)


pars = SimParameters(
	icrs_per_pack = ArenaSim.icrgen_qc(0.5,0,0),
	welcome_bundle = true,
	bonus_packs = Dict{Symbol,Int}(:M19 => 5, :GRN => 4)
	)

sets = ArenaSim.sets[1:5]

perm = [7, 2, 5, 8, 6, 3, 4, 1]
decks = decks[perm]
files = files[perm]


function f(i)
    res = simulate(10000, decks[i:i]; parameters =pars, sets = sets)
    res
end

zz = map(i -> f(i), 1:length(decks))

using PyCall
pygui()
using PyPlot


using Colors

pal = distinguishable_colors(9)
pal = "#" .* lowercase.(hex.(pal))

tot = ArenaSim.reduce_deck(reduce(vcat, decks); additive = false)
res2 = simulate(10000, [tot]; parameters = pars, sets = sets)


PyPlot.plt[:close]("all")
xmax = extrema( extrema(x.total_earned_packs) for x in zz)[2][2]
fig = figure(figsize = (11,8.5))
for i in 1:length(zz)
    subplot(3,3,i)
    PyPlot.plt[:hist]( zz[i].total_earned_packs, bins = -0.5:5:175.5, density = true, color = pal[i])
    title(files[i] * "\n" * string(rm_count(decks[i])), fontsize = 10)
    xticks(0:25:175)
end
subplot(3,3,9)
xr = extrema(res2.total_earned_packs)
PyPlot.plt[:hist](res2.total_earned_packs, color = pal[9], bins = 220:5:400, density = true)
title("All 8 lists crafted in bulk" * "\n" * string(rm_count(tot)), fontsize = 10)
suptitle("Pack Cost Estimates for Top 8 GP Lille Decklists in MTGA (assuming fresh account, welcome bundle purchased)")
figtext(0.5, 0.02, "Packs needed after welcome bundle and starting packs", horizontalalignment = "center", fontsize = "large")
figtext(0.015,  0.5, "Density",
rotation = "vertical", horizontalalignment = "right", verticalalignment="center",
fontsize = "large")
tight_layout(rect=[0.03, 0.03, 1, 0.95])
savefig("earned_pack_estimates.png")
