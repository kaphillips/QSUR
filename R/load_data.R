#' Read ToxPrints finger print file
#'
#' Import ToxPrint file from the ChemoTyper (`source="chemotyper"`) application
#' or from a batch download originating from the EPA CompTox Chemicals Dashboard
#' (`source="ccd"`) and return a tibble of the chemical identifier
#' (`chemical_id`) and the 729 ToxPrints features.
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
    toxps <- colnames(df)[which(!colnames(df) %in% c('chemical_id'))]
    attr(df,'toxprints') <- toxps
    return(df)
}


#' Load QSUR Models
#'
#' Import a named list of all 39 valid, structure-only QSUR models contained
#' within this package. Names of the list are the harmonized use predicted by
#' that randomForest object value in the named list.
#' @param harmonized_use name of model to use
#' @export
#' @examples
#' qsur_models()
qsur_models <- function(){
    return(QSUR:::qsurs)
}
