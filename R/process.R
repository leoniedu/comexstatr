cdircomex <- path.expand(rappdirs::user_cache_dir("comexr"))
ddircomex <- path.expand(rappdirs::user_data_dir("comexr"))




#' Merge and Format NCM Datasets from Comexstat
#'
#' This function retrieves multiple NCM (Nomenclatura Comum do Mercosul) datasets from the `comexstat` package,
#' merges them into a single data frame, and converts all columns to character format.
#'
#' @param files A character vector specifying the names of the NCM datasets to retrieve from `comexstat`.
#'   Defaults to `c('ncm', 'ncm_cgce', 'ncm_cuci', 'ncm_isic', 'ncm_unidade')`.
#'
#' @return A merged data frame containing all specified NCM datasets, with all columns converted to character format.
#'
#' @details
#' This function streamlines the process of working with multiple NCM datasets from the `comexstat` package. It performs the following steps:
#'
#' 1. **Retrieval:** Retrieves the specified NCM datasets using the `comex` function.
#' 2. **Merging:** Combines all retrieved datasets into a single data frame using left joins.
#' 3. **Format Conversion:** Converts all columns in the merged data frame to character format for consistent data manipulation.
#'
#' The function suppresses messages and warnings during the retrieval and merging steps to provide a cleaner output.
#'
#' @examples
#' \dontrun{
#' # Merge and format default NCM datasets
#' merged_ncms <- ncms()
#'
#' # Merge specific NCM datasets (e.g., only 'ncm' and 'ncm_cuci')
#' merged_ncms <- ncms(files = c('ncm', 'ncm_cuci'))
#' }
#'
#' @export
ncms <- function(files = c("ncm", "ncm_cgce", "ncm_cuci", "ncm_isic", "ncm_unidade")) {
    suppressMessages(suppressWarnings({
        ncms_list <- purrr::map(files, comex)
        ncms_merged <- Reduce(dplyr::left_join, ncms_list)
        ncms_merged |>
            dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
    }))
}




#' Aggregate Comex Data by Summing Columns with Matching Prefixes
#'
#' This function aggregates a Comex (Brazilian trade) dataset by calculating the sum of columns whose names
#' start with any of the specified prefixes.
#'
#' @param data A data frame or tibble containing Comex data.
#' @param x A character vector specifying the column name prefixes to match and sum.
#'   Defaults to `c('qt_stat', 'kg_net', 'fob_', 'freight_', 'insurance_', 'cif_')`, which captures common columns
#'   related to quantities, weights, and various costs.
#'
#' @return A tibble with one row containing the sum of each matched column. The column names in
#'   the result are the same as the input column names.
#'
#' @details
#' This function simplifies the process of aggregating multiple related variables in Comex data by allowing
#' you to specify prefixes instead of listing each column individually. For example, the default prefix `'fob_'`
#' would match columns like `fob_usd`, `fob_brl`, etc., and sum them all together.
#'
#' @examples
#' # Create a sample Comex dataset
#' comex_data <- data.frame(
#'   qt_stat = c(100, 250, 80),
#'   kg_net = c(5000, 12000, 3500),
#'   fob_usd = c(15000, 38000, 10000),
#'   fob_brl = c(75000, 190000, 50000),
#'   freight_usd = c(2000, 5000, 1500)  # Additional column with 'fob_' prefix
#' )
#'
#' # Aggregate columns starting with default prefixes
#' summary_data <- comex_sum(comex_data)
#' summary_data
#'
#' # Aggregate only columns starting with 'qt_' and 'fob_'
#' summary_data <- comex_sum(comex_data, x = c('qt_', 'fob_'))
#' summary_data
#'
#' @export
comex_sum <- function(data, x = c("qt_stat", "kg_net", "fob_", "freight_", "insurance_", "cif_")) {
    data |>
        dplyr::summarise(dplyr::across(dplyr::starts_with(x), sum, .names = "{.col}"))
}

#' Calculate Rolling Sums for Comex Data
#'
#' This function computes rolling sums over a specified window for selected columns in a Comex (Brazilian trade) dataset. It operates on columns that start with the specified prefixes.
#'
#' @param data A data frame or tibble containing Comex data, with a `date` column.
#' @param x A character vector specifying the prefixes of the column names for which to calculate rolling sums.
#'   Defaults to `c('qt_stat', 'kg_net', 'fob_', 'freight_', 'insurance_', 'cif_')`, which captures common columns
#'   related to quantities, weights, and various costs.
#' @param k An integer specifying the window size (in months) for the rolling sum calculation. Defaults to 12.
#'
#' @return A modified version of the input `data`, with new columns added for each selected column.
#'   The new column names are of the format '{original_col_name}_{k}', where `k` is the window size.
#'   These new columns contain the rolling sums for the corresponding original columns.  Rows with
#'   incomplete windows (less than `k` months of data) will have NA values in the new columns.
#'
#' @details
#' This function uses the `slider` package's `slide_index_dbl` function to efficiently calculate rolling sums.
#'
#' The rolling sum for each date is calculated by summing the values from the current date up to `k-1` months prior.
#' Since the `.complete` argument in `slide_index_dbl` is set to `TRUE`, the function will only calculate rolling sums
#' for dates where there are at least `k` months of prior data available. Rows with incomplete windows will have `NA` values.
#'
#' @examples
#' #' # Create sample Comex data
#' set.seed(123)
#' library(lubridate)
#' library(dplyr)
#' comex_data <- tibble::tibble(
#'   date = rep(seq(from = ymd('2023-01-01'), to = ymd('2023-12-01'), by = 'month'), each=2),
#'   direction=rep(c("imp", "exp"), 12),
#'   qt_stat = rpois(24, lambda = 100),
#'   fob_usd = runif(24, min = 500, max = 2000)
#' )
#' # Example usage with default prefixes and window size of 12 months, grouped by direction:
#' rolled_data <- comex_data%>%group_by(direction)%>%comex_roll()
#'
#' # Calculate 2-month rolling sums for columns starting with 'qt_' and 'fob_', grouped by direction:
#' rolled_data <- comex_roll(comex_data%>%group_by(direction), x = c('qt_', 'fob_'), k = 2)
#' rolled_data%>%arrange(direction, date)%>%filter(date<="2023-03-01")
#'
#' @export
comex_roll <- function(data, x = c("qt_stat", "kg_net", "fob_", "freight_", "insurance_", "cif_"), k = 12) {
    data |>
        dplyr::arrange(date) |>
        dplyr::collect() |>
        dplyr::mutate(dplyr::across(tidyselect::starts_with(x), ~slider::slide_index_dbl(.x = .x, .before = months(k -
            1), .complete = TRUE, .f = function(z) sum(z), .i = date), .names = "{.col}_{k}"))
}


#' Standardize and Validate NCM Codes
#'
#' This function cleans and optionally validates NCM (Nomenclatura Comum do Mercosul) codes.
#'
#' @param x A character vector containing NCM codes.
#' @param checkncm A logical flag indicating whether to perform NCM validation. Defaults to `TRUE`.
#'
#' @return A character vector of cleaned NCM codes.
#'   * Non-numeric characters are removed.
#'   * Empty strings are converted to `NA`.
#'   * If `checkncm` is `TRUE`, an error is raised if any non-NA values do not have exactly 8 characters.
#'
#' @details
#' NCM codes are standardized to contain only digits (0-9). This is important for consistency in data analysis and comparison.
#'
#' The optional validation step ensures that the cleaned NCM codes adhere to the expected format of 8 digits.
#'
#' @examples
#' # Clean and validate valid NCM codes
#' ncm(c('01012100', '02011000', 'invalid code'))  # Raises an error due to 'invalid code'
#'
#' # Clean without validation
#' ncm(c('01012100', '02011000', 'invalid code'), checkncm = FALSE)
#' # Returns: c('01012100', '02011000', NA)
#'
#' @export
ncm <- function(x, nchar = 8, checkncm = TRUE) {
    x <- gsub("[^0-9]", "", x)
    x[nchar(x) == 0] <- NA_character_
    if (checkncm) {
        if (!all(nchar(x |>
            na.omit()) == nchar)) {
            stop("Not all NCMs valid or NA!")
        }
    }
    x
}
