# TODO: IMPORT LIBRARIES NEEDED FOR PROJECT 3

import mysql.connector
import pandas as pd
import os
from mlxtend.frequent_patterns import association_rules, apriori
import graphviz
from sklearn import tree


# TODO: CHANGE GRAPHVIZ DIRECTORY
os.environ["PATH"] += os.pathsep + 'C:/Program Files (x86)/Graphviz2.38/bin'

# TODO: CHANGE MYSQL INFORMATION
HOST = 'localhost'
USER = 'root'
PASSWORD = None
SCHEMA = SCHEMA
team = 8

def part1():
    cnx = mysql.connector.connect(host=HOST, user=USER, password=PASSWORD)
    cursor = cnx.cursor()
    cursor.execute('SET GLOBAL innodb_buffer_pool_size=2*1024*1024*1024;')
    cursor.execute('USE %s;' % SCHEMA)
    # TODO: REQUIREMENT 1. WRITE MYSQL QUERY IN EXECUTE FUNCTION BELOW
    cursor.execute("""
        SELECT user_id, if(year=2017,1,-1) as vip, ifnull(review_count,0), ifnull(positive,0), ifnull(review_avg,0), ifnull(review_sum,0), ifnull(tip_count,0), ifnull(Tip_likes,0) as likes, ifnull(tip_avg,0), ifnull(tip_sum,0)
        FROM (SELECT U1.id as user_id, review_count, positive, review_avg, review_sum
              FROM user as U1
              LEFT JOIN(    SELECT user_id as idR, COUNT(*) as review_count, SUM(R1.useful)+SUM(R1.funny)+SUM(R1.cool) as positive, AVG(R1.text_length) as review_avg, SUM(R1.text_length) as review_sum
                            FROM review as R1
                            WHERE R1.date like '%2017%'
                            GROUP BY user_id)R
              ON U1.id=R.idR)UR
        INNER JOIN( SELECT id as user_id2, tip_count, Tip_likes, tip_avg, tip_sum
                    FROM user as U2
                    LEFT JOIN(  SELECT user_id as idT, COUNT(*) as tip_count, SUM(T1.likes) as Tip_likes, AVG(T1.text_length) as tip_avg, SUM(T1.text_length) as tip_sum
                                FROM tip as T1
                                WHERE T1.date like '%2017%'
                                GROUP BY T1.user_id)T
                    ON U2.id=T.idT)UT
        ON UR.user_id=UT.user_id2
        LEFT JOIN(SELECT user_id as idV, year
                  FROM vip_history as V
                  WHERE V.year=2017)V1
        ON UR.user_id=V1.idV
        WHERE review_count is not null or tip_count is not null
        """)
# R2
    rows = cursor.fetchall()

    classes = []
    features = []
    for row in rows:
        feature_row = []
        classes.append(row[1])
        for i in range(2, 10):
            feature_row.append(row[i])
        features.append(feature_row)


    DT1 = tree.DecisionTreeClassifier(criterion='gini', max_depth=5, min_samples_leaf=500)
    DT1.fit(X=features, y=classes)

    DT2 = tree.DecisionTreeClassifier(criterion='entropy', max_depth=5, min_samples_leaf=500)
    DT2.fit(X=features, y=classes)

    graph1 = tree.export_graphviz(DT1, out_file=None,
                                     feature_names=['review_count', 'positive', 'review_avg', 'review_sum',
                                                    'tip_count', 'likes', 'tip_avg', 'tip_sum'],
                                     class_names=['Normal', 'VIP'])
    graph1 = graphviz.Source(graph1)
    graph1.render('team08_gini', view=True)

    graph2 = tree.export_graphviz(DT2, out_file=None,
                                     feature_names=['review_count', 'positive', 'review_avg', 'review_sum',
                                                    'tip_count', 'likes', 'tip_avg', 'tip_sum'],
                                     class_names=['Normal', 'VIP'])
    graph2 = graphviz.Source(graph2)
    graph2.render('team08_entropy', view=True)

    cursor.close()


def part2():
    cnx = mysql.connector.connect(host=HOST, user=USER, password=PASSWORD)
    cursor = cnx.cursor()
    cursor.execute('SET GLOBAL innodb_buffer_pool_size=2*1024*1024*1024;')
    cursor.execute('USE %s;' % SCHEMA)
    cursor.execute('DROP VIEW IF EXISTS LVW_liked;')
    cursor.execute('DROP VIEW IF EXISTS LVW_liked_partial_users')
    # TODO: REQUIREMENT 4. WRITE MYSQL QUERY IN EXECUTE FUNCTIONS BELOW
    # LVW_liked
    cursor.execute('''
        CREATE VIEW LVW_liked AS
        SELECT DISTINCT lower(business.name) AS name, review.user_id  
        FROM business
        INNER JOIN review
        ON review.business_id=business_id 
        WHERE review.stars>=3 AND business.neighborhood=\'Westside\' AND city=\'Las Vegas\'
        ''')
    # LVW_liked_partial_users
    cursor.execute('''
    CREATE VIEW LVW_liked_partial_users AS
    SELECT DISTINCT lower(business.name) AS name, review.user_id
    FROM business 
    INNER JOIN review
    ON review.business_id=business.id
    WHERE review.stars>=3 AND business.neighborhood=\'Westside\' AND city=\'Las Vegas\' AND review.user_id IN
    (SELECT review.user_id  
     FROM review 
     INNER JOIN business 
     ON review.business_id=business.id
     WHERE business.neighborhood =\'Westside\' AND city=\'Las Vegas\' AND review.stars >=3
     GROUP BY review.user_id
    HAVING count(review.id) >= 2)''')
  
    # TODO: REQUIREMENT 4. WRITE MYSQL QUERY IN EXECUTE FUNCTIONS ABOVE

    # TODO: REQUIREMENT 5. MAKE HORIZONTAL DATAFRAME
    cursor.execute('select * from LVW_liked_partial_users')
    store_name = []
    user_id = []
    for row in cursor:
        store_name.append(str(list(row)[0]))
        user_id.append(str(list(row)[1]))

    df = pd.DataFrame({'store_name': store_name, 'user_id': user_id})
    df = df.drop_duplicates()
    df_final = df.groupby(['user_id', 'store_name']).size().unstack(fill_value=0)
    
    # TODO: REQUIREMENT 6. SAVE ASSOCIATION RULES

    frequent_itemsets = apriori(df_final, min_support=0.005, use_colnames=True)
    print(frequent_itemsets)
    rules = association_rules(frequent_itemsets, metric='lift', min_threshold=1)
    print(rules.to_string())

    rules.to_csv('team08_association.txt', header=True, index=True, sep='\t')

    cursor.close()


if __name__ == '__main__':
    part1()
    part2()
