#' Optimize over a range of budgets and survival thresholds
#'
#' @param benefits.matrix A [strategies]x[species] dataframe with named rows and columns
#' @param cost.vector A list of strategy costs
#' @param all.index An integer signifying the index of the strategy that combines all strategies
#' @param budgets A list of budgets over which to optimize. If NULL, a sensible range of budgets will be automatically generated
#' @param thresholds A list of survival thresholds over which to optimize, default = (50, 60, 70)
#' @param combo.strategies A combination object specifying which strategies are combinations of which other strategies
#' @param weights A named list of species weights
#'
#' @return A dataframe of optimization results
#' @export
#'
#' @examples
#' COMBO_info <- get(data("COMBO_info"))
#' benefits.matrix <- get(data("Bij_fre_01"))
#' cost.vector <- get(data("cost_fre_01"))$Cost
#' opt.results <- Optimize(benefits.matrix, cost.vector, combo.strategies=COMBO_info)
#' PlotResults(opt.results)
Optimize <- function(benefits.matrix, cost.vector,
                     all.index = NULL,
                     budgets = NULL,
                     thresholds = c(50.01, 60.01, 70.01),
                     combo.strategies = NULL,
                     weights = NULL) {

  combos <- combo.strategies

  if ( is.null(all.index) & is.null(combo.strategies) ){
    all.index <- nrow(benefits.matrix)
    warning(paste("No information supplied regarding strategy combinations. Assuming strategy number", all.index,
                  "to be the strategy which combines all strategies"))
  } else {
    if (!is.null(combo.strategies)) {
      # All index was supplied through a combo matrix
      non.empty <- apply(combo.strategies, 2, function(x) sum(x != ''))
      all.index <- which(non.empty == max(non.empty))
      if (!any(grepl("baseline", colnames(combo.strategies)))) {
        warning("Didn't find a baseline in the strategy combination matrix, assuming baseline strategy has index 1")
        all.index <- all.index + 1
      }
      combos <- parse.combination.matrix(combo.strategies)
    }
  }

  print(paste("All.index =", all.index))

  opt.results <- do.optimize.range(B = benefits.matrix,
                                   cost.vector = cost.vector,
                                   all.index = all.index,
                                   thresholds = thresholds,
                                   combo.strategies = combos,
                                   weights = weights)
  opt.results
}

