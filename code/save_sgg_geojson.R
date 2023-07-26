#########################################################
##
## Shapefile (경기도) to Geojson (시군구)
## 이광춘, 2023.06.20
##
#########################################################

## 0. 패키지 --------------------------------------------

library(tidyverse)
library(sf)
library(rgdal)

## 1. 데이터 --------------------------------------------
# 1.1. 시군구 행정동명 ----------------------------------

sgg_cd_tbl <- read_csv("data/(공통)셀블록도로행정동/경기도_시군구_행정동_명,CD.csv",
                       col_types = cols(.default = col_character())) %>% 
  mutate(MEGA_NM = iconv(MEGA_NM, "euc-kr", "utf-8"),
         CTY_NM  = iconv(CTY_NM, "euc-kr", "utf-8"),
         ADMI_NM  = iconv(ADMI_NM, "euc-kr", "utf-8")) 

sgg_cd_tbl

# 1.2. 지도 ---------------------------------------------
gg_dong_raw <- st_read("data/(공통)셀블록도로행정동/행정동경계/행정동경계_경기도/행정동경계_경기도_좌표4326.shp")

gg_dong_sf <- gg_dong_raw %>% 
  mutate(CTY_CD = str_sub(ADMI_CD, 1, 4))

sgg_dong_sf <- gg_dong_sf %>% 
  group_by(CTY_CD) %>% 
  group_nest() %>% 
  left_join(sgg_cd_tbl %>% count(CTY_CD, CTY_NM)) %>% 
  select(CTY_CD, CTY_NM, data)
  
## 2. 내보내기 --------------------------------------------

save_sgg_geojson <- function(shapefile, filename) {
  cat("\n--------------------\n", filename, "\n")
  sf::st_write(shapefile, glue::glue("data/sgg_map/{filename}.geojson"))
}

# save_sgg_geojson(sgg_dong_sf$data[[1]], "과천시")

walk2(sgg_dong_sf$data, sgg_dong_sf$CTY_NM, save_sgg_geojson)


## 3. 확인 --------------------------------------------

km_map <- sf::st_read("data/sgg_map/광명시.geojson")

plot(st_geometry(km_map)) 
  
