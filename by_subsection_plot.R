library(ggplot2)
library(haven)
library(tidyverse)


data <- read_dta("Scoring results/combined_results_long.dta")
colnames(data)
data <- data |> mutate(
  score = 3 - score,
  score = factor(score),
  subsection = factor(subsection),
  item_cat = factor(item_cat, labels = c("Other Sections", "Statistical Modelling ")),
                  model = factor(model, labels = c("Claude Sonnet", "Google Gemini Pro 2.5", "OpenAI GPT 5"))
) |> 
  filter(!is.na(score))

data |> group_by(model) |> 
  summarise(major = sum(score == 2),
            minor = sum(score == 1),
            correct = sum(score == 0),
            total = n())


data |> ggplot(aes(x = subsection, fill = score)) +
  geom_bar(position = "fill") +
  coord_flip()  +
  labs(
    x = NULL,
    y = "Value",
    fill = "Category"
  ) +
  theme_minimal() +
  scale_fill_manual(
    values = c(
      "0" = "transparent",   # white no issue
      "1" = "#fdae61",   # amber minor errors
      "2" = "#d73027",   # red major errors
      "3" = "#6a3d9a"   
    ),
    labels = c(
      "1" = "Minor errors",
      "2" = "Major errors",
      "3" = "Not covered"
    ),
    breaks = c("1", "2", "3")
  ) +
  facet_grid(
    rows = vars(item_cat),
    cols = vars(model),
    drop = TRUE,
    scales = "free_y",
    space = "free_y",
    as.table = FALSE,
    switch = "y"
  ) + 
  theme(
    legend.position = "top"
  ) +
  guides(
    fill = guide_legend(nrow = 1, byrow = TRUE)
  )

ggsave(
  filename = "Scoring results/plots/by_subsection_plot.png",
  width = 10,
  height = 6
)