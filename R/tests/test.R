ext_val_path <- "C:/Users/kphillip/OneDrive - Environmental Protection Agency (EPA)/Profile/Code/R/qsur/chemotyper_test_chems.tsv"
ext_val <- QSUR::read_toxprints(io=ext_val_path,source='chemotyper')

qsurs <- QSUR::qsur_models()

preds <- QSUR::predict_all_QSUR(qsurs,ext_val)
