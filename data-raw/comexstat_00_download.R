library(pins)
library(dplyr)


comexstat_check_urls <- c(
  "https://balanca.economia.gov.br/balanca/bd/comexstat-bd/ncm/IMP_TOTAIS_CONFERENCIA.csv",
  "https://balanca.economia.gov.br/balanca/bd/comexstat-bd/ncm/EXP_TOTAIS_CONFERENCIA.csv"
)
names(comexstat_check_urls) <- basename(comexstat_check_urls) %>%
  tolower() %>%
  tools::file_path_sans_ext()

comexstat_urls <- c(
  comexstat_check_urls,
  "https://balanca.economia.gov.br/balanca/bd/comexstat-bd/ncm/IMP_COMPLETA.zip",
  "https://balanca.economia.gov.br/balanca/bd/comexstat-bd/ncm/EXP_COMPLETA.zip",
  "https://balanca.economia.gov.br/balanca/bd/tabelas/NCM.csv",
  "https://balanca.economia.gov.br/balanca/bd/tabelas/PAIS_BLOCO.csv",
  "https://balanca.economia.gov.br/balanca/bd/tabelas/NCM_CUCI.csv",
  "https://balanca.economia.gov.br/balanca/bd/tabelas/NCM.csv",
  "https://balanca.economia.gov.br/balanca/bd/tabelas/NCM_ISIC.csv",
  "https://balanca.economia.gov.br/balanca/bd/tabelas/NCM_CGCE.csv",
  "https://balanca.economia.gov.br/balanca/bd/tabelas/PAIS.csv",
  "https://balanca.economia.gov.br/balanca/bd/tabelas/NCM_UNIDADE.csv"
)
names(comexstat_urls) <- basename(comexstat_urls) %>%
  tolower() %>%
  tools::file_path_sans_ext()

comexstat_board_url <- board_url(comexstat_urls)

comexstat_board <- board_local(versioned = FALSE)

check_imp <- pin_download(board = comexstat_board_url, name = "imp_totais_conferencia") %>% read.csv2()

local_imp <- tryCatch(pin_download(board = comexstat_board, name = "imp_totais_conferencia") %>% read.csv2(), error = function(e) tibble())

if (force_download | (!setequal(local_imp, check_imp))) {
  ds <- purrr::map(comexstat_board_url$urls %>% names(), ~ pin_download(board = comexstat_board_url, name = .x))
  names(ds) <- names(comexstat_board_url$urls)
  purrr::walk(names(ds), ~ pin_upload(comexstat_board, name = .x, paths = ds[[.x]]))
  unzip(comexstat_board %>% pin_download("exp_completa"), exdir = cdir)
  unzip(comexstat_board %>% pin_download("imp_completa"), exdir = cdir)
}
