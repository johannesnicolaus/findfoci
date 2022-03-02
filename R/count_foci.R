#' Count foci
#'
#' @param dir ImageJ output directory containing uncounted csv files.
#' @param sample_cells To perform downsampling on cells to N number of cells. Default is FALSE.
#' @param dose The unit of stimulation concentration.
#'  This must be written in the file name between underscores (e.g. "x_10ugml_x").
#' @param time The unit of time.
#'  This must be written in the file name between underscores (e.g. "x_10min_x").
#'
#' @return data frame containing cell identifier and foci count.
#' @export
#'
#' @examples count_foci("imagej_output")
count_foci <- function(dir = NA, sample_cells = F, dose = "ugml", time = "min"){
   if (dir.exists(dir) == F) {
     stop("Directory does not exist!")
   }

   # if (sample_cells == F) {
   #
   # }

  file_list <- list.files(dir, recursive = T, full.names = T)
  file_list <- file_list[grepl(".*csv", file_list)]

  final_list <- c()

  # count the foci
  for(i in 1:length(file_list)){

    csv <- file_list[i]

    # read csv
    res <- read.csv(csv, header = TRUE, stringsAsFactors = FALSE,
                    check.names = FALSE)

    # detect size of cells by the largest number
    cellsize <- (max(res$Area))

    # add cell id for cells and foci are left blank
    res$cell_id <- ifelse(res$Area == cellsize, res[,1], "")

    # count number of cells
    ncell <- sum(res$Area == cellsize)

    # find distance between foci and cell
    for(i in ncell+1:nrow(res)){
      #get distance between foci and cell
      distance <- (res[i,"XM"]-res[1:ncell,"XM"])^2+(res[i,"YM"]-res[1:ncell,"YM"])^2
      #get the cellid
      res[i,"cell_id"] <- match(min(distance),distance)
    }

    res <- na.omit(res)

    #calculate foci number
    res_counts <-  as.data.frame(table(res$cell_id))

    # -1 to not count cellid as foci
    res_counts[,2] <- res_counts[,2]-1

    res$foci_count <- rep(0, nrow(res))

    for(i in 1:nrow(res_counts)){
      res$foci_count <- ifelse(res$cell_id == res_counts[i,1], res_counts[i,2], res$foci_count)
    }

    final_list <- rbind(final_list, res[,-1])

  }


  # trim data frame
  final_list <- dplyr::filter(final_list, Area == max(Area))
  final_list <- dplyr::select(final_list, Label, cell_id, foci_count)

  # add dose and time
  final_list <- mutate(final_list,
                       dose = as.numeric(gsub(dose, "", unlist(strsplit(Label, '_'))[grepl(dose, unlist(strsplit(Label, '_')))])),
                       time = as.numeric(gsub(time, "", unlist(strsplit(Label, '_'))[grepl(time, unlist(strsplit(Label, '_')))]))
  )

  # sample cells
  if (sample_cells == F) {
    final_list <- final_list
  } else {
    if (sample_cells == "minimum")  {
      min_cells <- min(table(select(final_list, time, dose)))
      final_list <- dplyr::ungroup(dplyr::slice_sample(group_by(final_list, dose, time), n = min_cells))
    } else {
      final_list <- dplyr::ungroup(dplyr::slice_sample(group_by(final_list, dose, time), n = sample_cells))
    }
  }

  # return final dataframe
  return(final_list)

}




