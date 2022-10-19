ext_val_path <- "C:/Users/kphillip/OneDrive - Environmental Protection Agency (EPA)/Profile/Code/R/qsur/chemotyper_test_chems.tsv"
ext_val <- QSUR::read_toxprints(io=ext_val_path,source='chemotyper')

qsurs <- QSUR::qsur_models()


# preds <- QSUR::predict_QSUR(qsurs$additive,ext_val)
preds <- QSUR::predict_all_QSUR(qsurs,ext_val)

# tmp <- quick_predict(qsurs$additive,ext_val,type='prob')

# chemical_id <- "chemical_id"
# tmp_tib <- tibble::tibble({{chemical_id}}:=ext_val[[chemical_id]])
# for (qsur in names(qsurs)){
#     pred <- quick_predict(qsurs[[qsur]],ext_val,"")
#     tmp_tib[[qsur]] <- pred
# }
in_domain <- function(preds,chemical_id='chemical_id',sim_cut=0.5,method="jaccard",models){

    ## Get the original training set
    toxps <- attr(preds,'toxprints')
    training <- QSUR:::qsurs_train
    d_cuts <- QSUR:::d_cut
    domain <- tibble::tibble({{chemical_id}}:=preds[[chemical_id]])
    preds <- preds[,toxps]
   ## Loop over all models
    for (model in names(models)){

        ## Get the training set for a specific model, and only keep its
        ## descriptors.

        rows <- which(training[['harmonized_use']]==model)
        train <- training[rows,toxps]


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
        is_in <- sapply(d_ij,function(x){x < d_cut})
        if (length(is_in) != dim(domain)[1]){
            stop("is_in isn't the same as domain")
        }
        domain[[model]] <- as.vector(is_in)
   }
    ## Return data frame indices of records within domain of applicability

    return(domain)
}
