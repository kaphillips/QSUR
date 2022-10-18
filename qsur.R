read_toxprints <- function(source_type,){
    if (source_type == "chemotyper"){

    } else if (source_typer == 'ccd'){
        tb <-
    }
}

load_model <- function(path,harmonized_use){
    if (harmonized_use == "all") {
        ## Load all models
    } else if () {
        ## load single model
    } else {
        ## No option given, throw an error
    }
    return (model)
}

predict_model <- function(model,X){
    return (X_pred)
}


in_domain <- function(model,X_pred){

}

workflow <- function(model,X){
    if (model = NULL) {
     model <- load_model(path,harmonized_use)
    } else {
        preds <- predict_model(model,X)
        ad <- in_domain(model,X_pred)
    }
}
