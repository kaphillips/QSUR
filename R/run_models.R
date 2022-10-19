


model_predict <- function(model,df,type='prob'){
    if (type=="prob"){
        x <- as.vector(randomForest:::predict.randomForest(model,df,type=type)[,2])
    } else {
        x <- as.vector(randomForest:::predict.randomForest(model,df))
    }
    return(x)
}



#' Predict with a Single QSUR Model
#'
#' Predict a single harmonized use from a passed df of chemical ToxPrints
#' @param model randomForest model object
#' @param df ToxPrint DataFrame of chemicals to predict
#' @param type type of prediction to get from RF model (prob, response, or vote)
#' @param chemical_id name of chemical_id used, default is `chemical_id`
#' @export
#' @examples
#' predict_one_QSUR()

predict_one_QSUR <- function(model,df,type='prob',chemical_id='chemical_id'){
    preds <- tibble::tibble({{chemical_id}}:=df[[chemical_id]])
    preds[['probability']] <- model_predict(model=model,df=df,type=type)
    return (preds)
}



#' Predict with all 39 QSUR Models
#'
#' Predict all 39 valid harmonized uses from a passed df of chemical ToxPrints
#' @param model randomForest model object
#' @param df ToxPrint DataFrame of chemicals to predict
#' @param type type of prediction to get from RF model (prob, response, or vote)
#' @param chemical_id name of chemical_id used, default is `chemical_id`
#' @export
#' @examples
#' predict_all_QSUR()

predict_all_QSUR <- function(models,df,type='prob',chemical_id='chemical_id'){
    `%>%` <- dplyr::`%>%`
    preds <- lapply(models, QSUR:::model_predict, df=df, type=type)
    preds <- as.data.frame(do.call(cbind,preds))
    preds <- preds %>% tibble::add_column({{chemical_id}}:=df[[chemical_id]],
                                          .before=names(models)[1])

    preds <- preds %>% dplyr::mutate(dplyr::across({{chemical_id}},as.character))
    return(tibble::tibble(preds))
}



#' Predict if a record is in a model's domain of applicability
#'
#' For each record in a testing set of data, applicability_domain
#' determines if that record lies within the domain of applicability of the
#' training set for a given class in a classification model. See the following
#' for more information on these methods:
#' Rational selection of training and test sets for the development
#'   of valid QSAR models, A. Golbraikh, et al., J. Comp.-Aided Mol. Design,
#'   17 (2003), 241 -- 253.
#' Predictive QSAR modeling workflow, model applicability domains,
#'   and virtual screening, A. Tropsha and A. Golbraikh, Curr. Pharm. Design,
#'   13 (2007), 3494 -- 3504.
#'
#' @usage applicability_domain(predictions, sim_cut=0.5, metric="jaccard",
#'                             models=NULL)
#'
#' @param preds data.frame of n-chemical rows and m-functional use
#'   columns containing the probabilty that chemical i could fulfill functional
#'   use j
#' @param sim_cut fraction from 0 to 1 for how similar records should be, passed
#'   to similarity_threshold
#' @param method distance metric to use for similarity calculation
#' @param models list of models, or "classes", for which to determine domain
#' @export

in_domain <- function(preds,sim_cut=0.5,method="jaccard",models){

    ## Name the column in the training and predictions that will have the
    ## class that was known/predicted
    class_col <- 'harmonized_function'

    ## Get the original training set
    training <- QSUR:::qsurs_training
    d_cuts <- QSUR:::d_cut

    ## I left in the chemical ids and cluster numbers in the training set,
    ## drop these, and rename the 'category' column to 'harmonized_function'
    colnames(training)[which(colnames(training)=='category')] <- class_col
    training <- training[,which(colnames(training) %in% c(class_col,cols))]

    ## Get the names of all the valid models
    if (is.null(models)){
        cat("Loading QSUR models for prediction, this will take a few moments...")
        model_list <- names(QSURModels::qsur_model_list)
        cat("done.")
    } else {
        model_list <- names(models)
    }
    #
    # ## Initialize counter
    # i <- 0

   ## Loop over all models
   for (model in names(models)){

        ## Get the training set for a specific model, and only keep its
        ## descriptors.

        rows <- which(training[class_col]==model)
        train <- training[rows,]

        ## Get the predicted values for a specific model, and only keep its
        ## descriptors.
        cols <- which(colnames(predictions)==model)
        preds <- predictions[,cols]

        ## Throw message and skip if there are not enough records for the class in
        ## the training set.
        if (dim(train)[1] == 0){
            paste(c("not enough training for ",model),sep="",collapse="")
            next
        }

        ## Throw message and skip if there are not enough records for the class in
        ## the predicted set.
        if (dim(preds)[1] == 0){
            paste(c("not enough testing for ",model),sep="",collapse="")
            next
        }

        ## This is the similarity threshold that Tropsha uses in most of his QSAR
        ## validation work: d_cut <- Z*d_avg + d_std
        d_cut <- d_cuts[[model]]

        ## Caluculate the pair-wise distances between molecules in the training set
        ## and predictions
        d_train_preds <- proxy::dist(train,preds,method=method)

        ## Now that you know the distances see if they meet the threshold requirement
        ## Find the closed training chemical to the predicted chemicals, and store
        ## that distance
        d_ij <- apply(d_train_preds,2,"min")

        ## Now for each predicted chemical, see if that closest distance is less than
        ## the threshold distance
        in_domain <- sapply(d_ij,function(x){x < d_cut})

        # ## If it is, then store the index, if not then its not in the domain of
        # ## applicability and is not a valid prediction
        # if (i == 0){
        #     idx <- names(in_domain)[which(in_domain==TRUE)]
        # } else {
        #     idx <- c(idx,names(in_domain)[which(in_domain==TRUE)])
        # }
        #
        # i <- i + 1

   }
   ## Return data frame indices of records within domain of applicability
   return(predictions[idx,c('chemical_id','harmonized_function','probability')])
}

#
#
#
# in_domain <- function(model,X_pred){
#
# }
#
# workflow <- function(model,X){
#     if (model = NULL) {
#      model <- load_model(path,harmonized_use)
#     } else {
#         preds <- predict_model(model,X)
#         ad <- in_domain(model,X_pred)
#     }
# }
