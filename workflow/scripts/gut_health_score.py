# Read in functional profiling and gut health score
with open(snakemake.input.functional_profile) as f:
    pathways = f.read()

with open(snakemake.input.health_score) as f:
    score = f.read()

# Example nutritional recommendation logic
recommendations = "Based on your gut health score, we recommend:"

if "SCFA production" in pathways:
    recommendations += "\n - Increase fiber intake for short-chain fatty acid production."

if float(score.split(":")[1].strip()) < 70:
    recommendations += "\n - Consider probiotic supplements to improve gut diversity."

# Write the recommendations to a file
with open(snakemake.output.recommendations, "w") as f:
    f.write(recommendations)
