valid_uses <- function(){
    path <- list.files(path,pattern="*.rds",full.name=F)
    uses <- unlist(lapply(path,trim))
    return(uses)
}


load_model <- function(harmonized_use="all"){
    trim <- function(x){
        x <- basename(x)
        ## equiv: x.split("_")[:-2]
        x <- head(unlist(stringr::str_split(x,"_")),n=-2)
        return(stringr::str_c(x,collapse="_"))
    }

    path <- "../data/"
    if (harmonized_use == "all") {
        ## Load all models
        path <- list.files(path,pattern="*.rds",full.name=T)
        uses <- unlist(lapply(path,trim))
        model <- setNames(as.list(path),uses)
        model <- lapply(model,readRDS)
    } else {
        ## load single model
        model <- Sys.glob(file.path(path,stringr::str_glue("{harmonized_use}*.rds")))
        if (length(model) == 0){
            ## No valid use given, throw an error
            stop(stringr::str_glue("Unknown use {harmonized_use}. Use `valid_uses` for list of uses with available QSUR model."))
        } else{
            # Read in single model
            model <- readRDS(model)
        }
    }
    return (model)
}



read_toxprints <- function(io,source,chemical_id="chemical_id"){
    if (source == "chemotyper") {
        df <- readr::read_tsv(io)
        df <- dplyr::rename(df,{{chemical_id}}:="M_NAME")
    } else if (source == "ccd") {
        df <- readr::read_csv(io)
        df <- dplyr::rename(df,{{chemical_id}}:="INPUT")
    }
    ## The models were built using standard data.frames, but tibbles don't
    ## conver the column names, so force it
    colnames(df) <- colnames(data.frame(df))
    return(df)
}
