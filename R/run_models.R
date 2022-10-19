predict_model <- function(model,df,chemical_id='chemical_id'){
    df_pred <- randomForest:::predict.randomForest(model,df,type='prob')
    df_pred <- tibble(as.data.frame(cbind(df[[chemical_id]],preds[,2])))
    colnames(df_pred) <- c("chemical_id",'probability')
    df_pred <- df_pred %>% mutate(across(probability,as.double))
    return (df_pred)
}



# predict_model_list <- function(model,df){
#
# }
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
