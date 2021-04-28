### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ b5082844-5b0b-11eb-0397-8b4ec205d6e8
begin
using ESDL
md"The **ESDL** package implements the Earth system data lab datacube"
end

# ╔═╡ d947b62a-5c9d-11eb-3f72-c7c62f159328
begin
	using YAXArrays
md"The **YAXArrays** package implements xarray like data type for Julia which can handle named dimensions without invoking runtime costs. We use it in this tutorial to export the generated datacube as a zarr file."
end

# ╔═╡ bd6f1984-5b0b-11eb-021b-9f54c3ce4b32
begin 
using ArchGDAL
const AG = ArchGDAL
md"**ArchGDAL** is a wrapper of the GDAL library to load and work with geospatial data
We set the constante AG so that we don't have to always write ArchGDAL."
end

# ╔═╡ 28428d84-5b0c-11eb-094f-bfa8b9f57151
begin
using Dates
	md"**Dates** is the standard library to deal with temporal information"
end

# ╔═╡ ed5fe8c0-5b0c-11eb-3a56-3586e748a59d
begin
using Glob
	md"**Glob** is a package to implement file search after certain patterns"
end

# ╔═╡ 9b8003d6-5b3f-11eb-3264-d1ff9e8ff195
begin
using DisplayAs
md"
**DisplayAs** lets us determine how certain types are displayed.
	
This is needed, because the Pluto table viewer would overwrite the show method of the ESDL datacube and this would take too long.
	"
end

# ╔═╡ 09fd3af0-5b0d-11eb-3474-29b9d72d6ab6
md"# How to use raster datasets in the ESDL datacube"

# ╔═╡ 2744eda6-5b0d-11eb-1cb9-43150a1072e3
md" In this tutorial we explore how we can use the ESDL Julia datacube package to load and process raster datasets, which we can open with GDAL.
To do that we need a list of raster datasets which have the same spatial resolution and extent. In this tutorial we use a stack of Sentinel-1 time series which we have prepared with the pyroSAR package
"

# ╔═╡ a3620b3a-5b0d-11eb-2cdd-2b16725a420c
md"## Load relevant packages
First we need to load the relevant packages."

# ╔═╡ 29886c0a-5cb9-11eb-1203-77487bd1d00e


# ╔═╡ af21a08c-5b0c-11eb-0eda-c918eb6bd74b
md"## Select the input data
We need to set the directory where our input data is located. 
Here these are all tifs, but all other input files that are readable by GDAL should work as well."

# ╔═╡ c66ea2e8-5b0b-11eb-32a0-43848aa3a425
indir = "/home/crem_fe/Daten/bonds/jurua/tifs/" 

# ╔═╡ 6fa49dd4-5bd1-11eb-16b8-1bf744b159fe
md"Select the polarisation of the data, we use this to search for the files so that we could do datacubes with multiple variables."

# ╔═╡ d3e7d886-5b0d-11eb-3afa-113c79123d05
pol="VH"

# ╔═╡ d0ba9e9e-5bd3-11eb-13f6-cdc764877078
md"We search for .tif files in our input directory which include the polarisation string in their name."

# ╔═╡ e5315880-5b0c-11eb-3bd9-abd2abff6d95
filenames = glob("*$(pol)*.tif", indir)

# ╔═╡ f729546c-5bd3-11eb-308d-71d0aa082a40
md"## Sort input data by acquisition date 
We extract the time step information from every filename. 
The getdate function is defined in the Appendix and the . means broadcast application of the function. This means, that we apply the getdate function on every element in the list filenames to get a list of dates. 
"

# ╔═╡ 5b4ed6b2-5bd4-11eb-1511-c1beb810951d
md"To make sure that our input data is temporally ordered, we sort the dates vector and save the sorting permutation, so that we can apply this sorting on the filenames." 

# ╔═╡ df48ad2a-5bd5-11eb-0a2e-0bf846357f27
md"## Make spatial mosaics of single time steps 
We group entries together when their time stamps are less than 200 seconds apart, because they are coming from the same acquisition and we want to mosaic them spatially. 

The grouptimes function is defined in the appendix."

# ╔═╡ 600db524-5bd6-11eb-16d9-2bfbd1016cca
md"We define temporary paths for the spatial mosaic of every time step to save these mosaics as vrt files."

# ╔═╡ 29d8ddd0-5b11-11eb-1fe7-bb53a72018d9
md" Here we generate a VRT file for every time step to get spatial mosaics of the two Sentinel-1 scenes."

# ╔═╡ 4331ba22-5c9a-11eb-318e-d54c13d57667
md"## Bundle the datacube together
Now we can load the VRTs of every time step again and combine them into a large vrt file for the whole datacube."

# ╔═╡ 718ce9aa-5b39-11eb-36e9-a78b349422b9
md"We can open the vrt file we just constructed as a RasterDataset, which uses the DiskArrays package to get an Array interface for our data on the disk. 
"

# ╔═╡ 9611b3c6-5cb7-11eb-2962-cb592710e974
md"Now we can convert this data set into a YAXArray, so that we can either export it into the Zarr or NetCDF format or to analyse it in the ESDL datacube. 
We convert the third dimension into a Time axis so that we can handle the date information."

# ╔═╡ 19100244-101c-4118-a61e-7ce323cba98e


# ╔═╡ d489fee0-5b42-11eb-13f6-8312665a9b35
md"## Appendix"

# ╔═╡ bd69cbdc-5b0b-11eb-1b95-9f142ddd2fec
"""
   getdate(x,reg = r"[0-9]{8}T[0-9]{6}", df = dateformat"yyyymmddTHHMMSS")
Return a DateTime object from a string where the time stamp is found by `reg`
and it is parsed according to the `df` dateformat.
"""
function getdate(x,reg = r"[0-9]{8}T[0-9]{6}", df = dateformat"yyyymmddTHHMMSS")
   m = match(reg,x).match
   date =DateTime(m,df)
end

# ╔═╡ bd6efa9e-5b0b-11eb-1f54-a55e63bf6f8a
dates = getdate.(filenames)

# ╔═╡ bd6ed424-5b0b-11eb-0f94-036973a4b923
p = sortperm(dates)

# ╔═╡ 55bea62e-5b0e-11eb-172e-7bf04fdc91c4
begin
	sdates = dates[p]
	sfiles = filenames[p]
end

# ╔═╡ c1cc2b4e-5b0c-11eb-0e25-4dea8bdde02d
"""
grouptimes(times, timediff=200000)
Group a sorted vector of time stamps into subgroups
where the difference between neighbouring elements are less than `timediff` milliseconds.
This returns the indices of the subgroups as a vector of vectors.
"""
function grouptimes(times, timediff=200000)
   @assert sort(times) == times
   group = [1]
   groups = [group]

   for i in 2:length(times)
      t = times[i]
      period = t - times[group[end]]
      if period.value < timediff
         push!(group, i)
      else
         push!(groups, [i])
         group = groups[end]
      end
   end
   return groups
end

# ╔═╡ 6ced494c-5b0e-11eb-2f39-eb4faf365fda
groupinds = grouptimes(sdates, 200000)

# ╔═╡ 310eb3e0-5b11-11eb-01ce-952ed3e1a6c1
  tmppaths = [joinpath(tempdir(), splitext(basename(sfiles[group][1]))[1] * ".vrt") for group in groupinds]


# ╔═╡ 625de04e-5b11-11eb-1652-390e5d2339f3
begin
	vrt_grouped = AG.read.(tmppaths)
	vrt_all = AG.unsafe_gdalbuildvrt(vrt_grouped, ["-separate"])
end

# ╔═╡ 8fe86ece-5b39-11eb-1246-39d38f4fac1e
rvrt = AG.RasterDataset(vrt_all)

# ╔═╡ 1bd2ab12-5b11-11eb-397a-113991566052
begin 
	pathgroups = [sfiles[group] for group in groupinds]
	for (i,group) in enumerate(pathgroups)
		tmppath = tmppaths[i]
		AG.read(group[1]) do ds1
			AG.read(group[2]) do ds2
					ArchGDAL.gdalbuildvrt([ds1, ds2]) do vrt
						AG.write(vrt,tmppath)
					end
				end
			end
		end
	pathgroups
end

# ╔═╡ b28a6cba-5b3f-11eb-3fe9-b7c07f5249a6
cube = let
	dates_grouped = [sdates[group[begin]] for group in groupinds]
   taxis = RangeAxis(:Time, dates_grouped)
		cube = YAXArray(rvrt)
renameaxis!(cube, "Band"=>taxis);
end;

# ╔═╡ 9031368a-5b3f-11eb-1f18-9f753727b89f
cube |> DisplayAs.Text

# ╔═╡ ac061a56-5c9d-11eb-3710-39742a955b6b
let
	cubepath="myfancycube3.zarr"
	if !isdir(cubepath)
		savecube(cube, cubepath)
	end
end

# ╔═╡ 8dee753a-5bd1-11eb-298c-a50fc87a1514
"""
   gdalcube(indir, pol)

Load the datasets in `indir` with a polarisation `pol` as a ESDLArray.
We assume, that `indir` is a folder with geotiffs in the same CRS which are mosaicked into timesteps and then stacked as a threedimensional array.

"""
function gdalcube(indir, pol)

   filenames = glob("*$(pol)*.tif", indir)
   dates = getdate.(filenames)
   # Sort the dates and files by DateTime
   p = sortperm(dates)
   sdates = dates[p]
   sfiles = filenames[p]
   @show sfiles
   # Put the dates which are 200 seconds apart into groups
   groupinds = grouptimes(sdates, 200000)

   datasets = AG.read.(sfiles)
   datasetgroups = [datasets[group] for group in groupinds]
   #We have to save the vrts because the usage of nested vrts is not working as a rasterdataset

   temp = tempdir()
   outpaths = [joinpath(temp, splitext(basename(sfiles[group][1]))[1] * ".vrt") for group in groupinds]
   @show outpaths
   @show length(outpaths), length(datasetgroups)
   vrt_grouped = AG.unsafe_gdalbuildvrt.(datasetgroups)
   AG.write.(vrt_grouped, outpaths)
   vrt_grouped = AG.read.(outpaths)
   vrt_vv = AG.unsafe_gdalbuildvrt(vrt_grouped, ["-separate"])
   rvrt_vv = AG.RasterDataset(vrt_vv)
   cube=YAXArray(rvrt_vv)
   #bandnames = AG.GDAL.gdalgetfilelist(vrt_vv.ptr)



   # Set the timesteps from the bandnames as time axis
   dates_grouped = [sdates[group[begin]] for group in groupinds]

   taxis = RangeAxis(:Time, dates_grouped)
   YAXArrays.Cubes.renameaxis!(cube, "Band"=>taxis)
   return cube
end

# ╔═╡ 171e3594-5cb7-11eb-09a6-f9e79f3bc1be
cube_vv = gdalcube(indir, "VV")

# ╔═╡ b7048a82-5b3f-11eb-2750-bd06926f2184
cube_vv |> DisplayAs.Text

# ╔═╡ be71d8bc-5b3f-11eb-0389-8d8523e08f1e
fullcube = let 
	catax = CategoricalAxis("Polarisation", ["VH", "VV"])
	concatenatecubes([cube, cube_vv], catax)
end

# ╔═╡ defd3ef8-5b3f-11eb-1cdf-51a4b7ae925a
fullcube |>DisplayAs.Text

# ╔═╡ Cell order:
# ╟─09fd3af0-5b0d-11eb-3474-29b9d72d6ab6
# ╟─2744eda6-5b0d-11eb-1cb9-43150a1072e3
# ╟─a3620b3a-5b0d-11eb-2cdd-2b16725a420c
# ╠═b5082844-5b0b-11eb-0397-8b4ec205d6e8
# ╠═d947b62a-5c9d-11eb-3f72-c7c62f159328
# ╠═bd6f1984-5b0b-11eb-021b-9f54c3ce4b32
# ╠═28428d84-5b0c-11eb-094f-bfa8b9f57151
# ╠═ed5fe8c0-5b0c-11eb-3a56-3586e748a59d
# ╠═9b8003d6-5b3f-11eb-3264-d1ff9e8ff195
# ╠═29886c0a-5cb9-11eb-1203-77487bd1d00e
# ╠═af21a08c-5b0c-11eb-0eda-c918eb6bd74b
# ╠═c66ea2e8-5b0b-11eb-32a0-43848aa3a425
# ╠═6fa49dd4-5bd1-11eb-16b8-1bf744b159fe
# ╠═d3e7d886-5b0d-11eb-3afa-113c79123d05
# ╠═d0ba9e9e-5bd3-11eb-13f6-cdc764877078
# ╠═e5315880-5b0c-11eb-3bd9-abd2abff6d95
# ╠═f729546c-5bd3-11eb-308d-71d0aa082a40
# ╠═bd6efa9e-5b0b-11eb-1f54-a55e63bf6f8a
# ╠═5b4ed6b2-5bd4-11eb-1511-c1beb810951d
# ╠═bd6ed424-5b0b-11eb-0f94-036973a4b923
# ╠═55bea62e-5b0e-11eb-172e-7bf04fdc91c4
# ╠═df48ad2a-5bd5-11eb-0a2e-0bf846357f27
# ╠═6ced494c-5b0e-11eb-2f39-eb4faf365fda
# ╟─600db524-5bd6-11eb-16d9-2bfbd1016cca
# ╠═310eb3e0-5b11-11eb-01ce-952ed3e1a6c1
# ╠═29d8ddd0-5b11-11eb-1fe7-bb53a72018d9
# ╠═1bd2ab12-5b11-11eb-397a-113991566052
# ╟─4331ba22-5c9a-11eb-318e-d54c13d57667
# ╠═625de04e-5b11-11eb-1652-390e5d2339f3
# ╟─718ce9aa-5b39-11eb-36e9-a78b349422b9
# ╠═8fe86ece-5b39-11eb-1246-39d38f4fac1e
# ╟─9611b3c6-5cb7-11eb-2962-cb592710e974
# ╠═b28a6cba-5b3f-11eb-3fe9-b7c07f5249a6
# ╠═9031368a-5b3f-11eb-1f18-9f753727b89f
# ╠═19100244-101c-4118-a61e-7ce323cba98e
# ╠═ac061a56-5c9d-11eb-3710-39742a955b6b
# ╠═171e3594-5cb7-11eb-09a6-f9e79f3bc1be
# ╠═b7048a82-5b3f-11eb-2750-bd06926f2184
# ╠═be71d8bc-5b3f-11eb-0389-8d8523e08f1e
# ╠═defd3ef8-5b3f-11eb-1cdf-51a4b7ae925a
# ╟─d489fee0-5b42-11eb-13f6-8312665a9b35
# ╠═bd69cbdc-5b0b-11eb-1b95-9f142ddd2fec
# ╠═c1cc2b4e-5b0c-11eb-0e25-4dea8bdde02d
# ╠═8dee753a-5bd1-11eb-298c-a50fc87a1514
