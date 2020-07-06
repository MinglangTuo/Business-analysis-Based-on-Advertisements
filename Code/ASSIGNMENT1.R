

##加载相关的依赖包
require(readr)
require(dplyr)
require(doBy)
require(ggplot2)



##打包1天的相关文件进入文件夹
##STEP1: 读取文件夹里的文件，并且建立frame data（tbl）
files<-list.files(path = "C:/Users/Tyler.Tuo/Documents/R/DATA",pattern = "*.csv",full.names = T)
tbl<-sapply(files,read_csv,simplify=FALSE) %>% bind_rows(.id="id")

##STEP2: 筛选相关的数据
tbl$agecat<-cut(tbl$Age,c(0,29,39,49,59,108),labels = c("<30","30-39","40-49","50-59","60+"))
tbl$Gender<-factor(tbl$Gender,levels = c(0,1),labels= c("Female","Male"))
tbl$Signed_In <-factor(tbl$Signed_In,levels = c(0,1),labels=c("NO","YES"))
tbl_SignedIn<-tbl
tbl_SignedIn$CTR<-as.numeric(tbl$Clicks/tbl$Impressions)
tbl_ageFinsh<-na.omit(tbl)

##TASK1 
##STEP3：Plot the distribution of number impressions

#plot the relationship between age and impressions(geom_histogram)
ggplot(tbl_ageFinsh, aes(x=Impressions, fill=agecat))+ geom_histogram(binwidth=1)
ggsave(" the relationship between age and impressions.png")

#plot the relationship between gender and impressions(boxplot)
ggplot(tbl_ageFinsh, aes(x=Gender, y=Impressions, fill=Gender)) + geom_boxplot()
ggsave(" gender and impressions.png")

##plot the relationship between Signed_In and impressions(freqpoly)
ggplot(tbl_ageFinsh, aes(Impressions, colour = Signed_In)) +geom_freqpoly(binwidth = 1)
ggsave(" the relationship between Signed_In and impressions.png")

##Additon: plot the facets for the different agecats by the clicks
ggplot(tbl_ageFinsh, aes(x=Impressions, color=agecat))+ geom_freqpoly(binwidth=1)+facet_wrap(~ Clicks)
ggsave(" the facets for the different agecats by the clicks.png")

##STEP4:Plot the distribution of CTR
##筛选掉impression为0的行
tbl_ageFinsh$hasImps <-cut(tbl_ageFinsh$Impressions,c(-Inf,0,Inf))
tbl_ageFinsh<-filter(tbl_ageFinsh,tbl_ageFinsh$Impressions>0|is.na(tbl_ageFinsh$Impressions)==TRUE)

##STEP5:Plot of CTR by age(条形图）
tbl_ageFinsh$CTR<-as.numeric(tbl_ageFinsh$Clicks/tbl_ageFinsh$Impressions)
ggplot(tbl_ageFinsh,aes(x=CTR,fill=agecat))+geom_bar()
ggsave(" CTR by age(1).png")

ggplot(tbl_ageFinsh,aes(x=CTR,fill=agecat))+geom_bar(width=0.2)
ggsave(" CTR by age(2).png")


##STEP6:Plot of CTR by gender(条形图）
print(ggplot(tbl_ageFinsh,aes(CTR,fill=Gender))+geom_bar())
ggsave("  CTR by gender(1).png")

print(ggplot(tbl_ageFinsh,aes(CTR,fill=Gender))+geom_bar(width=0.2))
ggsave(" CTR by gender(2).png")

##STEP7:Plot of CTR by Signed_In(条形图）
ggplot(tbl_SignedIn,aes(CTR,fill=Signed_In))+geom_bar(width=0.2)
ggsave(" CTR by Signed_In(1).png")

##STEP8:Plot of density of CTR By agecat(频率直方图）  
ggplot(tbl_ageFinsh, aes(x=CTR,colour=agecat)) + geom_density()
ggsave(" CTR By agecat.png")

##STEP9:Plot of density of CTR By agecat(频率直方图|点击大于1）
ggplot(subset(tbl_ageFinsh, Clicks>0), aes(x=CTR,colour=agecat)) + geom_density()
ggsave(" CTR By agecat_click.png")

##Task2 分析小于18岁男生和女生的相关信息
#STEP9:筛选相关的数据(小于18岁）
tbl_task2<-filter(tbl_ageFinsh,Age<18|is.na(Age)==TRUE)
tbl_task2$Gender<-factor(tbl_task2$Gender,levels = c("Female","Male"),labels= c("Female(<18)","Male(<18)"))
siterange<-function(x){c(length(x),min(x),max(x),mean(x))}

#STEP10: the attributes of table are about length, min, max, mean, and we can obverse the differences between the males and females
tbl_task2= as.data.frame(tbl_task2)
print(summaryBy(Age~Gender,data=tbl_task2,FUN=siterange)) #analyse age for male and females
print(summaryBy(Signed_In+Impressions+Clicks~Gender,data=tbl_task2))


#分别筛选男女
tbl_Male<-filter(tbl_task2,Gender=="Male(<18)")
tbl_Female<-filter(tbl_task2,Gender=="Female(<18)")

#分别筛选年龄


tbl_task2$CTR<-tbl_task2$Clicks/tbl_task2$Impressions

tbl_task2$scode[tbl_task2$Impressions==0]<-"NoImps"
tbl_task2$scode[tbl_task2$Impressions >0]<-"Imps"
tbl_task2$scode[tbl_task2$Clicks==0]<-"Clicks"
tbl_task2$scode<-factor(tbl_task2$scode)


#绘制相关图片
ggplot(tbl_task2,aes(x=Impressions,fill= Gender))+geom_histogram()
ggsave(" Impressions for gender(small than 18).png")


ggplot(tbl_task2,aes(x=Signed_In,fill= Gender))+geom_bar()
ggsave("Signed_In for gender(small than 18).png")

ggplot(tbl_task2,aes(x=Clicks,fill= Gender))+geom_histogram()
ggsave(" Clicks for gender(small than 18).png")

ggplot(tbl_task2,aes(x=scode,fill= Gender))+geom_bar()
ggsave("  scode for gender(small than 18).png")

ggplot(tbl_task2,aes(x=CTR,fill= Gender))+geom_histogram()
ggsave(" CTR for gender(small than 18).png")

##TASK3
#metrics to the dates
tbl_task2<-filter(tbl_task2,tbl_task2$Impressions>0|is.na(tbl_task2$Impressions)==TRUE)

createMetrics<-function(df){
  print(summary(df)) #include max, min, CTR, quantiles, mean
  StrImpressions <-"the variance of Impressions is"
  StrClicks<-"the variance of Clicks is"
  StrAge<-"the variance of Age is"
  StrCTR<-"the variance of CTR is"
  
  print(paste(StrImpressions,var(df$Impressions)))
  print(paste(StrClicks,var(df$Clicks)))
  print(paste(StrAge,var(df$Age )))
  print(paste(StrCTR,var(df$CTR)))
  
}



tbl_Male<-filter(tbl_task2,Gender=="Male(<18)")
tbl_Female<-filter(tbl_task2,Gender=="Female(<18)")



#print the metrics
print(summary(tbl_task2))
Male<-createMetrics(tbl_Male)
Female<-createMetrics(tbl_Female)



##Task4
##打包10天的相关文件进入文件夹，手动excel加入属性Day
##STEP1: 读取文件夹里的文件，并且建立frame data（tbl）,天数已经安排完毕
files<-list.files(path = "C:/Users/Tyler.Tuo/Documents/R/R'",pattern = "*.csv",full.names = T)
tbl<-sapply(files,read_csv,simplify=FALSE) %>% bind_rows(.id="id")

#筛选数据（age）
tbl$agecat<-cut(tbl$Age,c(0,29,39,49,59,108),labels = c("<30","30-39","40-49","50-59","60+"))
tbl$Gender<-factor(tbl$Gender,levels = c(0,1),labels= c("Female","Male"))
tbl$Signed_In <-factor(tbl$Signed_In,levels = c(0,1),labels=c("NO","YES"))
tbl_ageFinsh<-na.omit(tbl)
#筛选数据（Impression）
tbl_ageFinsh$hasImps <-cut(tbl_ageFinsh$Impressions,c(-Inf,0,Inf))
tbl_ImpFinsh<-filter(tbl_ageFinsh,Impressions>0|is.na(tbl_ageFinsh$Impressions)==TRUE)

tbl_ImpFinsh$CTR<-as.numeric(tbl_ImpFinsh$Clicks/tbl_ImpFinsh$Impressions)

#STEP1 分析10天的数据（Impression/Clicks)并且分别绘制相关的表格
tb_new <- tbl_ImpFinsh %>%
  group_by(Day) %>% summarise(total_impressions = sum(Impressions),total_clicks = sum(Clicks))

  ggplot(tb_new,aes(x=Day))+geom_line(aes(y=total_impressions,color="impressions"))+ geom_line(aes(y=total_clicks,color="clicks"))

ggsave("CTR for 10 days.png")

#STEP2 分析gender有关数据
tb_new <- tbl_ImpFinsh %>%
  group_by(Day,Gender) %>% summarise(avg_CTR = mean(CTR))

  ggplot(tb_new,aes(x=Day,y=avg_CTR,color= Gender))+geom_line()+ geom_vline(xintercept=c(2,4,6,8),color = "green")

ggsave("gender for 10 days.png")

#STEP3 分析signed_in stauts
tb_new <- tbl_ImpFinsh %>%
  group_by(Day,Signed_In) %>% summarise(avg_CTR = mean(CTR))

  ggplot(tb_new,aes(x=Day,y=avg_CTR,color= Signed_In))+geom_line()+ geom_vline(xintercept=c(2,4,6,8),color = "green")

ggsave("Signed_In for 10 days.png")

#step4 分析agecat 
tb_new <- tbl_ImpFinsh %>%
  group_by(Day,agecat) %>% summarise(avg_CTR = mean(CTR))

  ggplot(tb_new,aes(x=Day,y=avg_CTR,color= agecat))+geom_line()+ geom_vline(xintercept=c(2,4,6,8),color = "green")

ggsave("agecat for 10 days.png")

#general paterns:
#The (<29) and (>55)people are liked to click when impressionss
#Signed in users are more like to engage with content
#girls whose age less then 18 years are more likely to click than boys.














