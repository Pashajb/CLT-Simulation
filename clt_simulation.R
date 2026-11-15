
# ============================================================
# Central Limit Theorem (CLT) Simulation
# Author: Pasha Jome Bozorgi
# ============================================================


# 1. Install and load required package

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages(
    "ggplot2",
    repos = "https://cloud.r-project.org"
  )
}

library(ggplot2)


# 2. Reproducibility

set.seed(42)


# 3. Simulation settings

n_simulations <- 2000
sample_sizes <- c(5, 30, 100, 500)


# 4. Define population distributions

distributions <- list(
  Exponential = function(n) rexp(n, rate = 1),
  Poisson = function(n) rpois(n, lambda = 4),
  Uniform = function(n) runif(n, min = 0, max = 1)
)


# 5. Define theoretical population parameters

population_parameters <- list(
  Exponential = c(mean = 1, sd = 1),
  Poisson = c(mean = 4, sd = 2),
  Uniform = c(mean = 0.5, sd = sqrt(1 / 12))
)


# 6. Generate sampling distributions

results <- data.frame()
normal_results <- data.frame()

for (dist_name in names(distributions)) {

  mu <- population_parameters[[dist_name]]["mean"]
  sigma <- population_parameters[[dist_name]]["sd"]

  for (n in sample_sizes) {

    # Generate repeated sample means

    sample_means <- replicate(
      n_simulations,
      mean(distributions[[dist_name]](n))
    )

    # Store empirical results

    temp <- data.frame(
      Distribution = dist_name,
      Sample_Size = factor(n, levels = sample_sizes),
      Sample_Mean = sample_means
    )

    results <- rbind(results, temp)

    # Generate theoretical normal approximation

    x_values <- seq(
      mu - 4 * sigma / sqrt(n),
      mu + 4 * sigma / sqrt(n),
      length.out = 300
    )

    normal_temp <- data.frame(
      Distribution = dist_name,
      Sample_Size = factor(n, levels = sample_sizes),
      Sample_Mean = x_values,
      Density = dnorm(
        x_values,
        mean = mu,
        sd = sigma / sqrt(n)
      )
    )

    normal_results <- rbind(normal_results, normal_temp)
  }
}


# 7. Calculate empirical and theoretical statistics

summary_table <- data.frame()

for (dist_name in names(distributions)) {

  mu <- population_parameters[[dist_name]]["mean"]
  sigma <- population_parameters[[dist_name]]["sd"]

  for (n in sample_sizes) {

    sample_means <- results$Sample_Mean[
      results$Distribution == dist_name &
      as.character(results$Sample_Size) == as.character(n)
    ]

    empirical_mean <- mean(sample_means)
    empirical_sd <- sd(sample_means)

    theoretical_mean <- as.numeric(mu)
    theoretical_sd <- as.numeric(sigma / sqrt(n))

    temp_summary <- data.frame(
      Distribution = dist_name,
      Sample_Size = n,
      Empirical_Mean = empirical_mean,
      Theoretical_Mean = theoretical_mean,
      Mean_Error = abs(empirical_mean - theoretical_mean),
      Empirical_SD = empirical_sd,
      Theoretical_SD = theoretical_sd,
      SD_Error = abs(empirical_sd - theoretical_sd)
    )

    summary_table <- rbind(
      summary_table,
      temp_summary
    )
  }
}


# Round numeric columns only

numeric_columns <- sapply(summary_table, is.numeric)

summary_table[numeric_columns] <- lapply(
  summary_table[numeric_columns],
  round,
  digits = 6
)


# Display summary statistics

cat("\nSTATISTICAL SUMMARY\n")
cat("===================\n")

print(summary_table)


# 8. Visualize sampling distributions

plot <- ggplot(
  results,
  aes(x = Sample_Mean)
) +

  geom_histogram(
    aes(y = after_stat(density)),
    bins = 35,
    fill = "steelblue",
    color = "white",
    alpha = 0.85
  ) +

  geom_line(
    data = normal_results,
    aes(
      x = Sample_Mean,
      y = Density
    ),
    color = "darkred",
    linewidth = 0.9,
    inherit.aes = FALSE
  ) +

  facet_wrap(
    vars(Distribution, Sample_Size),
    scales = "free",
    nrow = 3
  ) +

  labs(
    title = "Central Limit Theorem Simulation",
    subtitle = paste(
      "Empirical sampling distributions vs.",
      "theoretical normal approximations"
    ),
    x = "Sample Mean",
    y = "Density",
    caption = paste(
      "Blue: Empirical distribution",
      "| Red: Theoretical normal approximation"
    )
  ) +

  theme_minimal(base_size = 11) +

  theme(
    plot.title = element_text(
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(size = 10),
    strip.text = element_text(face = "bold"),
    panel.spacing = grid::unit(1, "lines")
  )


# Display plot

print(plot)


# 9. Save output files

if (!dir.exists("figures")) {
  dir.create("figures")
}

# Save visualization

ggsave(
  filename = "figures/clt_simulation.png",
  plot = plot,
  width = 14,
  height = 10,
  dpi = 300
)

# Save statistical summary

write.csv(
  summary_table,
  file = "figures/simulation_summary.csv",
  row.names = FALSE
)


# 10. Completion message

cat("\n====================================\n")
cat("Simulation completed successfully!\n")
cat("====================================\n")

cat("Plot: figures/clt_simulation.png\n")
cat("Summary: figures/simulation_summary.csv\n")
