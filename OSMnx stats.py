import osmnx as ox, networkx as nx, matplotlib.cm as cm, pandas as pd, numpy as np
ox.config(log_file=True, log_console=True, use_cache=True)

# create network from that bounding box
location_point = (32.8450, 13.1928)
G = ox.graph_from_point(location_point, distance=500, distance_type='bbox', network_type='all_private')
G_projected = ox.project_graph(G)
ox.plot_graph(G_projected)

# save street network as ESRI shapefile to work with in GIS
ox.save_graph_shapefile(G, filename='network-shape')

# calculate basic street network metrics and display average circuity
# for density: basic_stats = ox.basic_stats(G, area=???)
basic_stats = ox.basic_stats(G)
print(basic_stats['n'],basic_stats['edge_length_total'],basic_stats['circuity_avg'])

#extended_stats = ox.extended_stats(G, bc=True)
#print(extended_stats['betweenness_centrality_avg', 'closeness_centrality_avg'])
