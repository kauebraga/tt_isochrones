library(readr)
library(dplyr)
library(opentripplanner)
library(data.table)
library(sf)

# otpcon = otp_for
# fromPlace = c(-38.566889, -3.735398)
# mode = "WALK"
# dist = c(3000, 5000, 10000)
# walkSpeed = 1

# function to get isocrhones based on distance
# walk speed on meters/second
# dist on meters
get_isochrone <- function(fromPlace, dist, walk_speed = 3.6, ...) {
  
  # convert from meters to sec
  x_speed <- walk_speed/3.6
  x_times <- dist/x_speed
  
  iso <- otp_isochrone(fromPlace = fromPlace,
                       cutoffSec = x_times,
                       walkSpeed = x_speed,
                       ...)
  
  # add distance information to the output
  iso <- iso %>% mutate(distance = dist[length(dist):1])
  
}


# FORTALEZA -----------------------------------------------------------------------------------

# run this to make sure no other instance of otp is running on the background
otp_stop()

# run this and wait until the message "INFO (GrizzlyServer.java:153) Grizzly server running." show up
# may take a few minutes for a big city
otp_setup(otp = "otp/programs/otp.jar", dir = "otp", router = "for", port = 8080, wait = FALSE)

# register the router
otp_for <- otp_connect(router = "for")

# apply function
a <- get_isochrone(otpcon = otp_for,
                   fromPlace = c(-38.566889, -3.735398),
                   mode = "WALK",
                   dist = c(1000, 2000, 3000),
                   walk_speed = 3.6)


# visualize the ischrones
library(mapdeck)
set_token("")



mapdeck() %>%
  add_polygon(
    data = a,
    fill_colour = "distance",
    legend = TRUE
    
    
  )



# BELEM ---------------------------------------------------------------------------------------

# otp ocasional servers
otp_stop()
# turn on localhost for belem
otp_setup(otp = "otp/programs/otp.jar", dir = "otp", router = "bel", port = 8080, wait = FALSE)

# connect otp to belem
otp_bel <- otp_connect(router = "bel")

# open coordinates
coords_bel <- fread("data/coords_stations_prob_bel.txt", header = FALSE, sep = "\t")
# rename colum
coords_bel <- coords_bel[, .(geometry = V1)]
# create stop id
coords_bel <- coords_bel[, id_stop := 1:.N]
# delete commas
coords_bel <- coords_bel[, geometry := ifelse(id_stop == nrow(coords_bel), geometry, stringr::str_sub(geometry, start = 1, end = -2))]
# delete ()
coords_bel <- coords_bel[, geometry := gsub("\\(|\\)", "", geometry)]
# extract coords
coords_bel <- tidyr::separate(coords_bel, geometry, c("lat", "lon"), sep = ",") 
# transform to sf (not really necessary to calculate isocrhone, just for test viz)
coords_bel_sf <- st_as_sf(coords_bel, coords = c("lon", "lat"), crs = 4326)
mapview::mapview(coords_bel_sf)

# create lists of coordinates
coords_list <- purrr::map2(as.numeric(coords_bel$lon), as.numeric(coords_bel$lat), c)

# apply isochrones to list of coordinates
a <- lapply(coords_list, get_isochrone, 
            dist = c(250, 500, 750),
            mode = "WALK",
            otpcon = otp_bel,
            walk_speed = 3.6)

# bind output and transform to sf
a_sf <- rbindlist(a) %>% st_sf(crs = 4326)

# vizzzzzzzzzzzz
library(mapdeck)
set_token("")
set_token("pk.eyJ1Ijoia2F1ZWJyYWdhIiwiYSI6ImNqa2JoN3VodDMxa2YzcHFxMzM2YWw1bmYifQ.XAhHAgbe0LcDqKYyqKYIIQ")


mapdeck() %>%
  add_polygon(
    data = a_sf,
    fill_colour = "distance",
    legend = TRUE
    
    
  )


  