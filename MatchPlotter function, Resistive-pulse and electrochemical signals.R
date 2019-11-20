##Plotting function to generate a number of publication quality plots.
##Statistical significance is assessed using ANOVA.  Boxplots are chosen to 
##compactly display and compare distributions of different dependent variables.

my.theme<- theme(plot.title=element_text(size=30, family="Arial"), 
                 plot.subtitle=element_text(size=24, family="Arial"),
                 axis.line = element_line(colour = "black",size=1.0),
                 axis.text.x=element_text(colour="black", size=14, family="Arial"),
                 axis.text.y=element_text(colour="black", size=14, family="Arial"),
                 axis.title=element_text(colour="black", size=18, family="Arial"), 
                 panel.grid.major = element_blank(),
                 panel.grid.minor = element_blank(),
                 legend.position="none",
                 legend.text=element_text(colour="black", size=14, family="Arial"),
                 strip.text.x= element_text(colour="black", size=12, family="Arial"),
                 axis.ticks=element_line()+
                   theme_set(theme_tufte())
)



mainDir <- "Main Directory"
subDir <- "Figures directory"

##Setting the Working directory for the day's graphs

if (file.exists(subDir)){
  setwd(file.path(mainDir, subDir))
} else {
  dir.create(file.path(mainDir, subDir))
  setwd(file.path(mainDir, subDir))
  
}


plt.fnc <- function(frm){
  ylim<- 3*median(frm$Value)
  PLT <- ggplot(frm,aes(x="Independent Variable",y=Value, fill="Sorting Variable", colour="Sorting Variable",group="Sorting Variable")) +
    geom_boxplot(size=0.9)+
    stat_compare_means(method = "anova", label.y = 15)+      # Add global p-value
    stat_compare_means(label = "p.signif", method = "t.test",
                       ref.group = "Control Group", label.y=13)+
    coord_cartesian(ylim=c(0,ylim))+
    scale_y_continuous(expand = c(0,0))+
    
    labs(	x=expression("Independent Variable"),
          y=frm$Variable)+
    theme_tufte() +
    my.theme
  
  ggsave(PLT,file=paste0('PLOT_IdentifierVariable',frm$Variable[1],'.tiff'),units = "in", width=5,height=5, dpi = 600)
  
  return(PLT)
}

Plots <- correlatedMatches %>%
  gather(Variable,Value,Imax:Duration) %>% # this is equivilent to melt.
  group_by(Variable) %>%               # itterates over values of variable
  do(Plot = plt.fnc(.))      

