#####| WQP DATA CLEANING CODE   |###########################################
#####| Created by: Oliver Nguyen |###########################################
#####| Date: 08/23/2020         |###########################################
############################################################################

############################################################################
#PART 1: RESHAPING DATA ###################################################
library(tidyr)

#Biological Habitat Metrics
SD_bio <- read.csv("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Biological Habitat Metrics/USSD_biohab_metrics_raw.csv")
SD_bio_wide <- reshape(SD_bio, idvar = "MonitoringLocationIdentifier", timevar = "IndexTypeIdentifier", direction = "wide")
for ( col in 1:ncol(SD_bio_wide)){
  colnames(SD_bio_wide)[col] <-  sub("IndexScoreNumeric.", "", colnames(SD_bio_wide)[col])
}
write.csv(SD_bio_wide, "C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Biological Habitat Metrics/SD_biohab_metrics_wide.csv")



#Result Quantitation Limit 
SD_res <- read.csv("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Result Detection Quantitation Limit Data/SD_res_quantdet_raw.csv")
SD_res_wide <- reshape(SD_res, idvar = "MonitoringLocationIdentifier", timevar = "CharacteristicName", direction = "wide")
for ( col in 1:ncol(SD_res_wide)){
  colnames(SD_res_wide)[col] <-  sub("DetectionQuantitationLimitMeasure.MeasureValue.", "", colnames(SD_res_wide)[col])
}
write.csv(SD_res_wide, "C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Result Detection Quantitation Limit Data/SD_res_quantdet_wide.csv")



#Results (Biological Metadata)

SD_bio_meta <- read.csv("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Sample results (biological metadata)/USSD_ALL_JB_Sample results (biological metadata).csv")
library(tidyr)


#creating a unique ID combining monitoring location identifier and sampling activity ID 
SD_bio_meta$MonitoringID = paste(SD_bio_meta$MonitoringLocationIdentifier, SD_bio_meta$ActivityIdentifier)
SD_bio_meta2 <- reshape(SD_bio_meta, timevar = "CharacteristicName", idvar = c("MonitoringLocationIdentifier","ActivityIdentifier"), direction = "wide")

for ( col in 1:ncol(SD_bio_meta2)){
  colnames(SD_bio_meta2)[col] <-  sub("MeasureValue.", "", colnames(SD_bio_meta2)[col])
}

write.csv(SD_bio_meta2, "C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Sample results (biological metadata)/SD_bio_meta_wide.csv")

#Results (Narrow)
SD_sample_narrow <- read.csv("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Sample results (narrow)/USSD_ALL_JB_Sample results (narrow).csv")
SD_sample_narrow2 <- reshape(SD_sample_narrow, idvar = "MonitoringLocationIdentifier", timevar = "CharacteristicName", direction = "wide")
write.csv(SD_sample_narrow2, "C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Sample results (narrow)/sample_narrow_wide.csv")

#Results (Physical/Chemical)

############################################################################
####PART 2: JOINING DATA & CREATING SHP FILES###############################

#Load in shapefiles 
library(raster)

#All SD Sites
SD_all <- shapefile("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Site data/SD_sites2.shp")
#Only SD bioregion sites
SD_bioregion <- shapefile("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Site data/SD_sites_bioregion.shp")


########  A) Habitat Metrics ############

SD_biohab_met <- read.csv("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Biological Habitat Metrics/SD_biohab_metrics_wide.csv")
SD_biohab_meta_merged <- merge(SD_all, SD_biohab_met, by.x='Monitoring', by.y='MonitoringLocationIdentifier')
shapefile(SD_biohab_meta_merged, "C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Biological Habitat Metrics/SD_biohab_metrics_all.shp", overwrite =TRUE)

######## B) Project Monitoring Location ############

SD_prj_monloc <- read.csv("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Project Monitoring Location Weighting data/USSD_ALL_JB_Project Monitoring Location Weighting data.csv")

#remove duplicate rows
SD_prjmonloc_nodupe <- SD_prj_monloc[!duplicated(SD_prj_monloc$MonitoringLocationIdentifier), ]

SD_prj_monloc_merged <- merge(SD_all, SD_prjmonloc_nodupe, by.x='Monitoring', by.y='MonitoringLocationIdentifier')
shapefile(SD_prj_monloc_merged, "C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Project Monitoring Location Weighting data/SD_prj_monloc.shp", overwrite =TRUE)


######## C) Result Detection Quantitation Limit ########################
SD_result_quant_limit <- read.csv("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Result Detection Quantitation Limit Data/SD_res_quantdet_wide.csv")
SD_result_quant_limit_merged <- merge(SD_all, SD_result_quant_limit, by.x='Monitoring', by.y='MonitoringLocationIdentifier')
shapefile(SD_result_quant_limit_merged, "C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Result Detection Quantitation Limit Data/SD_result_quant.shp", overwrite = TRUE)

#remove duplicate rows
SD_prjmonloc_nodupe <- SD_prj_monloc[!duplicated(SD_prj_monloc$MonitoringLocationIdentifier), ]

######## D) Biological Meta Data #####################################
SD_bio_meta_csv <- read.csv("C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Sample results (biological metadata)/SD_bio_meta_wide.csv")
SD_bio_meta_merged <- merge(SD_all, SD_bio_meta_csv, by.x='Monitoring', by.y='MonitoringLocationIdentifier')
shapefile(SD_bio_meta_merged, "C:/Users/The Reckoning/Box/Database Inventory/Data/WQP/JB_Sample results (biological metadata)/SD_bio_meta_2.shp", overwrite = TRUE)

#Merge data together
SD_merge_resq <- merge(SD_res_quantdet_wide, USSD_All_JB_Site.data, by.x = "MonitoringLocationIdentifier", by.y = "MonitoringLocationIdentifier")
head(SD_merge_resq)

install.packages("raster")
install.packages("gdal")
install.packages("sp")

#make into shapefile  
write.csv(SD_merge_resq, "SD_merge_resq.csv")
