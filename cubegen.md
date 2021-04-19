# Introduction

This document shall summarize thoughts and instructions on how data cubes can be generated in the context of the DeepCube project. 
This is supposed to be a living document and shall be updated whenever new achievements have been made. 

## Status quo of the Earth System Data Cube

One of the project partners (MPG) was active in the consortium and co-created the so-called Earth System Data Cube. The idea behind this dataset was to bring together as many global Earth observation products as possible and make them ready for seamless multivariate analysis. 
Because of the research interest of the involved science partners, the focus of this data cube was to particularly enable efficient multivariate time series analysis on global datasets. In order to achieve this, we decided to regrid all involved 
variables to a common spatiotemporal grid. Although this involved some data duplication and increase of storage, we concluded
that instant access to a variety of datasets preferable. 
The initial plan for the DeepCube project (according to the proposal) was to use the cube generation software used to generate the ESDC to create custom data cubes for the single use cases 

## Communicated Requirements by the users

As a result of the DeepCube kickoff meeting as well as individual discussions it became apparent that the current data cube model, that does a regridding to a common spatiotemporal resolution is not feasible for most of the use cases. 
The main problem is that many data either come on high spatial and low temporal resolution (e.g. Sentinel, MODIS) or on high temporal and low spatial resolution (e.g. ERA5). In order to bring datasets of these different scale together with the ESDC approach, on would have to interpolate heavily, which would drastically increase the data volume. 
Therefore many of the use cases dealing with large data volumes were interested in so-called multi-resolution data cubes, 
where 

# Cube Generation - Howto

## General considerations

- need to bring all data into a single spatial reference system
- unify metadata by loading into a common framework (xarray)
- save the data and hope for Dask to solve chunking problems

