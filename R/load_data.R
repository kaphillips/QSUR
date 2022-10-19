#' Get valid QSUR model names
#'
#' Return a list of all valid structure-only QSUR models contained in package
#' @export
#' @examples
#' valid_uses()

valid_uses <- function(){
    path <- list.files(path,pattern="*.rds",full.name=F)
    uses <- unlist(lapply(path,trim))
    return(uses)
}



#' Read ToxPrint file for prediction
#'
#' Read in ToxPrint file either from the ChemoTyper application or the CCD
#' @param io path and name of file to read
#' @param source either `chemotyper` or `ccd`
#' @param chemical_id name of chemical_id used, default is `chemical_id`
#' @export
#' @examples
#' read_toxprintsl()

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

    ## Now, there can be ToxPrints that are either NULL or that have all 0
    ## values for a substance. Warn the user that these are being removed.
    toxps <- colnames(ext_val)[which(!colnames(ext_val) %in% c('chemical_id'))]
    attr(df,'toxprints') <- toxps
    return(df)
}





#' Load QSUR Models
#'
#' Load list of all or a single QSUR model
#' @param harmonized_use name of model to use
#' @export
#' @examples
#' qsur_models()
qsur_models <- function(harmonized_use){
    return(QSUR:::qsurs)
}
