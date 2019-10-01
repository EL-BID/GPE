# Alexandr (Sasha) Trubetskoy
# October 2018
# trub@uchicago.edu

import time
import logging
import argparse
import itertools
import numpy as np
import pandas as pd
import networkx as nx
from scipy import spatial, special
from tqdm import tqdm, tqdm_pandas

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

tqdm.pandas() # Gives us nice progress bars
parser = argparse.ArgumentParser() # Allows user to put no-borders in command line
parser.add_argument('--run_from_cmd_line', '-run', help='To run directly in Terminal', action='store_true')
parser.add_argument('--matrix_suffix', '-matrix', help='what suffix to use for matrices', type=str, default='')

parser.add_argument('--theta', '-t', help='elasticity parameter', type=float, default=5.03)
parser.add_argument('--beta', '-b', help='labor share', type=float, default=0.65)
parser.add_argument('--alpha', '-a', help='labor share', type=float, default=0.05)
parser.add_argument('--min_cost', '-m', help='minimum travel cost (ad valorem)', type=float, default=0.000048)
parser.add_argument('--retail_cost', '-r', help='minimum travel cost (ad valorem)', type=float, default=0.55)
parser.add_argument('--year', '-yr', help='year for population and GDP', type=int, default=2015)

parser.add_argument('--use_population', '-pop', help='use population instead of GDP', action='store_true')
parser.add_argument('--include_ext', '-ext', help='include external markets', action='store_true')
parser.add_argument('--reverse_trade', '-rev', help='reverse direction of trade', action='store_true')
parser.add_argument('--hummels_schaur', '-hs', help='use if comparing DH to HS costs', action='store_true')
parser.add_argument('--self_access', '-self', help='use if comparing DH to HS costs', action='store_true')

args = parser.parse_args()

# 0. Set file names
#---------------------------------------------------
CSV_STEM = 'data/cost_matrices/'+['overall','hummels_schaur'][args.hummels_schaur]+'/matrix_'
PRE_CSV = CSV_STEM + 'pre' + args.matrix_suffix + '.csv'
POST_CSV = CSV_STEM + 'post' + args.matrix_suffix + '.csv'

CITIES_CSV = 'data/csv/cities'+['','_hummels_schaur'][args.hummels_schaur]+'.csv'
EXTERNAL_TSV = 'data/csv/external_markets.csv'
OUTPUT_CSV = ''.join(['data/market_access/full_results',
            '_' + str(args.theta),
            PRE_CSV.split(CSV_STEM)[1][3:-4],
            ['','_beta'+str(args.beta)][(args.beta != 0.65)],
            ['','_min'+str(args.min_cost)][(args.min_cost != 0.000048)],
            ['','_yr'+str(args.year)][(args.year != 2015)],
            ['','_pop'][args.use_population],
            ['','_rev'][args.reverse_trade],
            ['','_hs'][args.hummels_schaur],
            ['','_self'][args.self_access],
            '.csv'])
if args.run_from_cmd_line:
    logger.info('File will export to {}.'.format(OUTPUT_CSV))
#---------------------------------------------------


# 1. Read cost matrices
#---------------------------------------------------
def read_cost_matrices():
    logger.info('Reading cost matrices...')
    matrix_pre = pd.read_csv(PRE_CSV, index_col=0)
    matrix_post = pd.read_csv(POST_CSV, index_col=0)
    # Minimum cost, to prevent crazy values for cities that happen to be very close to each other
    matrix_pre = matrix_pre.clip(lower=args.min_cost)
    matrix_post = matrix_post.clip(lower=args.min_cost)
    return matrix_pre, matrix_post
#---------------------------------------------------


# 2. Read cities and external markets
#---------------------------------------------------
def read_cities_and_externals():
    logger.info('Reading cities and external markets...')
    cities = pd.read_csv(CITIES_CSV)
    externals = {}
    if args.include_ext:
        with open(EXTERNAL_TSV) as file:
            header_line = next(file)
            for line in file:
                origin, destination, len_km, market, gdp, pop = line.strip().split('\t')
                externals[destination] = {'Population': int(pop), 'GDP': int(gdp)}
    return cities, externals
#---------------------------------------------------


# 3. Run MA
#---------------------------------------------------
def calc_market_access(city_i, cost_matrix, cities, externals, include_ext=args.include_ext, theta=args.theta, use_pop=args.use_population):
    FMA, CMA = 0, 0
    N = 'Population '+str(args.year) if use_pop else 'GDP '+str(args.year) # Space after, because column is called "GDP 2015"

    # First get external market terms
    if include_ext:
        for ext in externals:
            travel_cost_id = cost_matrix.loc[city_i][ext] # Cost to export from i -> d
            travel_cost_oi = cost_matrix.loc[ext][city_i] # Cost to import from o -> i

            FMA = (1/travel_cost_id)**theta * externals[ext][N] # Firm Market Access
            CMA = (1/travel_cost_oi)**theta * externals[ext][N] # Consumer Market Access

    # Then add terms for all other cities as in Donaldson & Hornbeck 2016
    t0 = time.time()
    for i in range(len(cities)):
        logger.debug(city_i, i, cities.iloc[i]['City Name'])
        logger.debug(time.time())
        other_city = cities.iloc[i]['City Name']
        if other_city == city_i:
            if args.self_access:
                travel_cost_id = args.retail_cost
                travel_cost_oi = args.retail_cost
            else: # skip self
                continue
        else:
            if args.reverse_trade:
                travel_cost_id = cost_matrix.loc[city_i][other_city] + [0, args.retail_cost][args.self_access]
                travel_cost_oi = cost_matrix.loc[other_city][city_i] + [0, args.retail_cost][args.self_access]
            else:
                travel_cost_id = cost_matrix.loc[other_city][city_i] + [0, args.retail_cost][args.self_access]
                travel_cost_oi = cost_matrix.loc[city_i][other_city] + [0, args.retail_cost][args.self_access]

            if travel_cost_id < 0: # Skip city pairs where cost is set to -1, a dummy value
                continue

        logger.debug('        ', time.time())
        FMA += (1/travel_cost_id)**theta * cities.iloc[i][N] # Firm Market Access
        logger.debug('FMA done', time.time())
        CMA += (1/travel_cost_oi)**theta * cities.iloc[i][N] # Consumer Market Access
        logger.debug('CMA done', time.time())

    return max([FMA, 1e-99]), max([CMA, 1e-99]) # in case MA = 0, prevent division errors later

def add_ma_cols(row, pre_matrix, post_matrix, cities, externals):
    current_city_name = row['City Name']
    FMA_pre, CMA_pre = calc_market_access(current_city_name, pre_matrix, cities, externals)
    FMA_post, CMA_post = calc_market_access(current_city_name, post_matrix, cities, externals)

    row['ln FMA_pre'] = np.log(FMA_pre)
    row['ln CMA_pre'] = np.log(CMA_pre)
    row['ln MA_pre'] = np.log(FMA_pre) + args.beta*np.log(CMA_pre) # Initial overall market access
    
    row['ln FMA_post'] = np.log(FMA_post)
    row['ln CMA_post'] = np.log(CMA_post)
    row['ln MA_post'] = np.log(FMA_post) + args.beta*np.log(CMA_post) # Final overall market access

    row['ln FMA_hat'] = np.log(FMA_post/FMA_pre) # Change in firm market access
    row['ln CMA_hat'] = np.log(CMA_post/CMA_pre) # Change in consumer market access
    row['ln MA_hat'] = row['ln FMA_hat'] + args.beta*row['ln CMA_hat'] # Change in total market access
    
    row['Added land value'] = args.alpha*row['GDP 2015']*(((np.e**row['ln MA_hat'])**(1/(1+args.alpha*args.theta)))-1)
    return row

#---------------------------------------------------

if args.run_from_cmd_line:
    m_pre, m_post = read_cost_matrices()
    cities, externals = read_cities_and_externals()
    
    logger.info('3. Calculating market access...')
    cities = cities.progress_apply(add_ma_cols, axis=1, args=(m_pre, m_post, cities, externals))    
    logger.info('\nMarket access calculated.')
    
    logger.info('4. Exporting to {}...'.format(OUTPUT_CSV))
    cities.to_csv(OUTPUT_CSV, index=False)
    logger.info('All done.')