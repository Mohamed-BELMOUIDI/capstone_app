### Word Generator Script
### Path: /home/mohamed.belmouidi/capstone/script/wordGenerator.R

# Set working directory and paths
ROOT_DIR <- "/home/mohamed.belmouidi/capstone"
DATA_DIR <- file.path(ROOT_DIR, "data")
TEMP_DIR <- file.path(DATA_DIR, "temp")

# Create directories if they don't exist
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TEMP_DIR, showWarnings = FALSE, recursive = TRUE)

# Load required packages
packages <- c("tidyverse", "tm", "SnowballC", "stringi", "data.table")
invisible(lapply(packages, function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install.packages(pkg)
        library(pkg, character.only = TRUE)
    }
}))

# Download and extract data
download_corpus <- function() {
    url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
    zip_path <- file.path(TEMP_DIR, "Dataset.zip")
    
    if (!file.exists(zip_path)) {
        message("Downloading dataset...")
        download.file(url, zip_path, method = "auto")
    }
    
    if (!dir.exists(file.path(TEMP_DIR, "final"))) {
        message("Extracting dataset...")
        unzip(zip_path, exdir = TEMP_DIR)
    }
}

# Load and sample data
load_data <- function(sample_size = 0.1) {
    en_path <- file.path(TEMP_DIR, "final/en_US")
    
    data_files <- list(
        twitter = file.path(en_path, "en_US.twitter.txt"),
        news = file.path(en_path, "en_US.news.txt"),
        blogs = file.path(en_path, "en_US.blogs.txt")
    )
    
    # Read and sample data
    set.seed(42)
    corpus <- lapply(data_files, function(file) {
        lines <- readLines(file, encoding = "UTF-8", warn = FALSE)
        sample(lines, size = ceiling(length(lines) * sample_size))
    })
    
    unlist(corpus)
}

# Clean text
clean_text <- function(text) {
    text %>%
        str_replace_all("\\b(won't)\\b", "will not") %>%
        str_replace_all("\\b(can't)\\b", "cannot") %>%
        str_replace_all("'ve\\b", " have") %>%
        str_replace_all("'m\\b", " am") %>%
        str_replace_all("'s\\b", "") %>%
        str_replace_all("n't\\b", " not") %>%
        str_replace_all("'ll\\b", " will") %>%
        str_replace_all("'re\\b", " are") %>%
        str_replace_all("(f|ht)tp(s?)://\\S+", "") %>%
        str_replace_all("@\\S+", "") %>%
        str_to_lower() %>%
        str_replace_all("[^[:alnum:][:space:]']", " ") %>%
        str_trim() %>%
        str_squish()
}

# Generate n-grams
generate_ngrams <- function(text, n) {
    # Create tokens
    words <- unlist(str_split(text, "\\s+"))
    
    # Generate n-grams
    ngrams <- data.table(
        text = sapply(seq_len(length(words) - (n-1)), function(i) {
            paste(words[i:(i + n-1)], collapse = " ")
        })
    )
    
    # Count frequencies
    ngrams <- ngrams[, .N, by = text]
    setnames(ngrams, "N", "freq")
    
    # Split into columns
    ngrams[, c(paste0("word", 1:n)) := tstrsplit(text, " ")]
    ngrams[, text := NULL]
    
    return(ngrams)
}

# Main execution
main <- function() {
    message("Starting word generator...")
    
    # Download and load data
    download_corpus()
    text <- load_data()
    
    # Clean text
    message("Cleaning text...")
    clean <- clean_text(text)
    
    # Generate n-grams
    message("Generating n-grams...")
    bigrams <- generate_ngrams(clean, 2)
    trigrams <- generate_ngrams(clean, 3)
    quadgrams <- generate_ngrams(clean, 4)
    
    # Save n-grams
    message("Saving n-grams...")
    saveRDS(bigrams, file.path(DATA_DIR, "bigram.RData"))
    saveRDS(trigrams, file.path(DATA_DIR, "trigram.RData"))
    saveRDS(quadgrams, file.path(DATA_DIR, "quadgram.RData"))
    
    # Clean up temp files
    unlink(TEMP_DIR, recursive = TRUE)
    
    message("Word generator completed successfully!")
}

# Run the script
main()
