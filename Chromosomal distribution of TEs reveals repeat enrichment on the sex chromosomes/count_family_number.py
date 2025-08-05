from collections import defaultdict
 
# Initialize a dictionary to store the family clusters
family_clusters = defaultdict(set)
 
# Read the file
with open("../cd_hit_out/cd_hit_80.2.fa.clstr", "r") as file:
    lines = file.readlines()
 
current_cluster = None
 
# Iterate through the lines in the file
for line in lines:
    if line.startswith(">Cluster"):
        # Extract the current cluster number
        current_cluster = int(line.split()[-1])
    elif current_cluster is not None:
        # Look for lines containing family information
        family_parts = line.split(">")
        if len(family_parts) > 1:
            family_info = family_parts[1].split("#")
            if len(family_info) > 1:
                family_name = family_info[1].split("...")[0]
                family_clusters[family_name].add(current_cluster)
 
# Calculate the number of clusters for each family
family_counts = {family: len(clusters) for family, clusters in family_clusters.items()}
 
# Print the results
for family, count in family_counts.items():
    print(family, count)
