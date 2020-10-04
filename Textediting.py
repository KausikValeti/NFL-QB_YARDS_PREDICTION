# -*- coding: utf-8 -*-
"""
Created on Fri Apr 10 17:40:58 2020

@author: vkaus
"""

import pandas as pd
import numpy as np
import re
import matplotlib.pyplot as plt
#####################################################################################################################################
# Merging datasets to train and test csv file
df_2014 = pd.read_csv(r"C:\Users\vkaus\OneDrive\Desktop\Masters\Semster-3\OR-603\Webscrapping_Script-R\NFL-Project12014.csv")
df_2015 = pd.read_csv(r"C:\Users\vkaus\OneDrive\Desktop\Masters\Semster-3\OR-603\Webscrapping_Script-R\NFL-Project12015.csv")
df_2016 = pd.read_csv(r"C:\Users\vkaus\OneDrive\Desktop\Masters\Semster-3\OR-603\Webscrapping_Script-R\NFL-Project12016.csv")
df_2017 = pd.read_csv(r"C:\Users\vkaus\OneDrive\Desktop\Masters\Semster-3\OR-603\Webscrapping_Script-R\NFL-Project12017.csv")
df_2018 = pd.read_csv(r"C:\Users\vkaus\OneDrive\Desktop\Masters\Semster-3\OR-603\Webscrapping_Script-R\NFL-Project12018.csv")

# Using df_2019 test
df_2019 = pd.read_csv(r"C:\Users\vkaus\OneDrive\Desktop\Masters\Semster-3\OR-603\Webscrapping_Script-R\NFL-Project12019.csv")
#########################################################################################################################################
# Train data modification
df_train = pd.concat([pd.concat([df_2014,df_2015,df_2016,df_2017,df_2018], axis=0)]).to_csv('train.csv')
df_train =pd.read_csv(r"C:\Users\vkaus\OneDrive\Desktop\Masters\Semster-3\OR-603\Webscrapping_Script-R\train.csv")
list(df_train.columns) #Displaying list of columns
df_train.drop(["Unnamed: 0"],axis=1,inplace=True) #Droping unnecessary column

# Creating dummy values for specific columns
df_train['name'] = "dummy"
df_train['pass_complete'] = "dummy"
df_train["direction"] = "dummy"
df_train["other_player"] = "dummy"
df_train["yards_thrown"] = 0

df_train.dropna(subset=["Detail"], inplace=True) #Removing nas from column Detail

def test1(row):
    pattern1 = re.compile("(\w+\s*\w*) (pass complete) (\w+\s*\w*) to (\w+\s*\w*) for (\d+) .*")
    pattern2 = re.compile("(\w+\s*\w*) (pass incomplete) (\w+\s*\w*) intended for (\w+\s*\w*) .*")
    results1 = pattern1.match(row[5])
    results2 = pattern2.match(row[5])
    if results1 != None:
        results1 = results1.groups()
        row[9] = results1[0]
        row[10] = "yes"
        row[11] = results1[2]
        row[12] = results1[3]
        row[13] = results1[4]
    if results2 != None:    
        results2 = results2.groups()
        row[9] = results2[0]
        row[10] = "NO"
        row[11] = results2[2]
        row[12] = results2[3]
        row[13] = 0
    return row
   
df_train = df_train.apply(test1, 1) #Making changes to all rows in specified columns using above user defined function
df_train.drop(["Time","Location"],axis=1,inplace=True) #Droping 2 columns 
df_train.dropna(subset=["Detail","Down","ToGo"], inplace=True)# Droping nas in specific columns
df_train=df_train[~df_train.name.str.contains("dummy")] #Removing dummy text in name column
df_train = df_train.to_csv("NFL-Train.csv")# Converting dataframe to csv

#########################################################################################################################################
# Test data Modification
df_test = df_2019.to_csv('test.csv')
df_test = pd.read_csv(r"C:\Users\vkaus\OneDrive\Desktop\Masters\Semster-3\OR-603\Webscrapping_Script-R\test.csv")
df_test.drop(["Unnamed: 0"],axis=1,inplace=True) #Droping unnecessary column

# Creating dummy values for specific columns
df_test['name'] = "dummy"
df_test['pass_complete'] = "dummy"
df_test["direction"] = "dummy"
df_test["other_player"] = "dummy"
df_test["yards_thrown"] = 0

df_test.dropna(subset=["Detail"], inplace=True)#Removing nas from column Detail

def test2(row):
    pattern1 = re.compile("(\w+\s*\w*) (pass complete) (\w+\s*\w*) to (\w+\s*\w*) for (\d+) .*")
    pattern2 = re.compile("(\w+\s*\w*) (pass incomplete) (\w+\s*\w*) intended for (\w+\s*\w*) .*")
    results1 = pattern1.match(row[5])
    results2 = pattern2.match(row[5])
    if results1 != None:
        results1 = results1.groups()
        row[9] = results1[0]
        row[10] = "yes"
        row[11] = results1[2]
        row[12] = results1[3]
        row[13] = results1[4]
    if results2 != None:    
        results2 = results2.groups()
        row[9] = results2[0]
        row[10] = "NO"
        row[11] = results2[2]
        row[12] = results2[3]
        row[13] = 0
    return row
   
df_test = df_test.apply(test2, 1)#Making changes to all rows in specified columns using above user defined function
df_test.drop(["Time","Location"],axis=1,inplace=True) #Droping 2 columns 
df_test.dropna(subset=["Detail","Down","ToGo"], inplace=True) # Droping nas in specific columns
df_test=df_test[~df_test.name.str.contains("dummy")] #Removing dummy text in name column
df_test = df_test.to_csv("NFL-Test.csv") # Converting dataframe to csv

#################################################################################################################################################

#Building a ANN model

dataset_train = pd.read_csv('NFL-Train.csv')
dataset_test = pd.read_csv('NFL-Test.csv')
df = pd.concat([pd.concat([dataset_train,dataset_test], axis=0)]).to_csv('Final-NFL.csv')
df = pd.read_csv('Final-NFL.csv')
df = df.dropna()
df=df[(df.direction != 'left') & (df.direction != 'right') & (df.direction != 'middle')]
list(df.columns.values)
df = df.drop(['Unnamed: 0.1','Unnamed: 0','Detail','name','pass_complete','other_player'],axis=1)
X = df.iloc[:, 0:8].values
#Y = df.iloc[:, -1:].values


# Encoding categorical data
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
labelencoder_X = LabelEncoder()
X[:, 6] = labelencoder_X.fit_transform(X[:, 6])
onehotencoder = OneHotEncoder(categorical_features = [6])
X = onehotencoder.fit_transform(X).toarray()
X = X[:, 1:]


X=pd.DataFrame(X)
list(X.columns.values)
X_t = X[X[10] <= 2018]
Y_t= X[X[10] == 2019]
X_train = X_t.iloc[:,0:10].values
Y_train = X_t.iloc[:,-1:].values
X_test = Y_t.iloc[:,0:10].values
Y_test = Y_t.iloc[:,-1:].values

# Feature Scaling
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)


# Tuning the ANN
from keras.wrappers.scikit_learn import KerasClassifier
from sklearn.model_selection import GridSearchCV
from keras.models import Sequential
from keras.layers import Dense
def build_classifier(optimizer):
    classifier = Sequential()
    classifier.add(Dense(units = 6, kernel_initializer = 'uniform', activation = 'relu', input_dim = 10))
    classifier.add(Dense(units = 6, kernel_initializer = 'uniform', activation = 'relu'))
    classifier.add(Dense(units = 1, kernel_initializer = 'uniform', activation = 'linear'))
    classifier.compile(optimizer = optimizer, loss = 'binary_crossentropy', metrics = ['accuracy'])
    return classifier
classifier = KerasClassifier(build_fn = build_classifier)
parameters = {'batch_size': [20,30,40],
              'epochs': [100, 200,300,400,500],
              'optimizer': ['adam', 'rmsprop']}
grid_search = GridSearchCV(estimator = classifier,
                           param_grid = parameters,
                           scoring = 'accuracy',
                           cv = 10)
grid_search = grid_search.fit(X_train, Y_train)
best_parameters = grid_search.best_params_
best_accuracy = grid_search.best_score_

