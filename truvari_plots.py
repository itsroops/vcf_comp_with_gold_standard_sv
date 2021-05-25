# Importing necessary packages
import sys
import pandas as pd
import csv
import os
import glob
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import xlsxwriter
from string import ascii_uppercase


def autolabel(rects,ax):
    """
    Attaching a text label above each bar in *rects*, displaying its height.
            
    Parameters: 
    rects: Individual bar plot object
    ax: The object for each subplot.
            
    Returns:
    Does not return anything
            
    """
    for rect in rects:
        height = rect.get_height()
        ax.annotate('{}'.format(height),
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom')


def truvari_plots(filepath):
    """
    Plots the combined barplots of the performance metrices for structural variants
            
    Parameters: 
    None of the paramennters are required
    
    Returns:
    Does not return anything
            
    """
    
    # Selecting the files that need to be compared
    #filepath=sys.argv[1]
    mylist = [f for f in glob.glob(filepath + "/*.summary.txt")]

    # Initializing lists for metrics calculations
    metric_recall=[]
    metric_precision=[]
    metric_f1=[]
    
    for i in range(0,len(mylist)):
        
        # Reading the files
        jsonfile=open(mylist[i],'r')
        jsondata=jsonfile.read()

        # Parsing the json data and creating a json object
        jsonobj=json.loads(jsondata)
        
        # Extracting the performance metrices from the json object
        metric_recall.append(jsonobj['recall'])
        metric_precision.append(jsonobj['precision'])
        metric_f1.append(jsonobj['f1'])
        
    # Initializing the label list
    labels=[]
    k = mylist[0].count("/")

    # Extracting the file names
    for i in mylist:
        p = i.split("/",k)[-1]
        p=p.split(".")[:-2]
        p=".".join(p)
        labels.append(p)

    
     # Finding the lengest filename
    longest_string = max(labels, key=len)
    
    # Finding the length of the file with the longest filename
    maxl = len(longest_string)
    
    # Making the excel file containing the metrices
    
    # Initializing the excel workbook
    workbook = xlsxwriter.Workbook('Analysis.xlsx')
    worksheet = workbook.add_worksheet('Metrics Scores.xlsx')

    # Setting the cell width
    worksheet.set_column('A:A', maxl)
    worksheet.set_column('B:D', 10)

    # Create a format to use as header
    header_format = workbook.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': '#D7E4BC'})

    # Defining the cell format for the values
    cell_fmt = workbook.add_format({'align': 'center','valign': 'vcenter', 'border': 1, 'num_format': '0.00'})
    
    # Displaying the header
    worksheet.write(0,0,'File Names', header_format)
    worksheet.write(0,1,'Precision', header_format)
    worksheet.write(0,2,'Recall', header_format)
    worksheet.write(0,3,'F1 Score', header_format)
    
    row=1
    
    for i in range(len(labels)):
        worksheet.write(row,0,labels[i], cell_fmt)
        worksheet.write(row,1,metric_precision[i], cell_fmt )
        worksheet.write(row,2,metric_recall[i], cell_fmt)
        worksheet.write(row,3,metric_f1[i], cell_fmt)
        row=row+1
    
    # Closing the workbook
    workbook.close()
        
    # Plotting for combined barplot for each individual performance metrices
    
    title="Bar_Chart_for_Performance_Metrices"
    
    data = [metric_precision, metric_recall, metric_f1]
    
    # Setting the label locations
    x = np.arange(len(labels))  

    # Setting the width of the bars
    width = 0.2  
    
    k=0

    # Setting the plot size for each plot
    fig, ax = plt.subplots(figsize =(10, 7))

    # Drawing the bars of its correspondng data
    rects1 = ax.bar(x - width, data[k], width, label='Precision')
    rects2 = ax.bar(x, data[k+1], width, label='Recall')
    rects3 = ax.bar(x + width, data[k+2], width, label='F1 Score')

    k=k+3

    # Adding some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel('Metrics Scores',fontweight ='bold')
    ax.set_xlabel('File Names',fontweight ='bold')
    ax.set_title(title)
    ax.set_xticks(x)
    ax.set_ylim([0,1])
    ax.set_xticklabels(labels, rotation=90)
    ax.legend(bbox_to_anchor=(1.05,1), loc='upper left')
    plt.yticks([0.00,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.65,0.70,0.75,0.80,0.85,0.90,0.95,1.00])
    plt.savefig(filepath  + "/" + title + ".pdf", format="pdf", bbox_inches = 'tight')
    plt.ioff()
       
    autolabel(rects1,ax)
    autolabel(rects2,ax)
    autolabel(rects3,ax)

    fig.tight_layout()

    plt.show()
