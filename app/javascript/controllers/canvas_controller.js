import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['winsLosses', 'barChart', 'barChartData'];

    connect() {
      this.colors=['#FBEC51', '#0091D2'];
      this.fontColor='#666';
      if (this.hasWinsLossesTarget) {
        this.drawWinLossesCharts();
      }
      if (this.hasBarChartTarget) {
        this.drawRankingChart();
      }
    }

    drawRankingChart(){
      const colors = this.colors.reverse();
      const canvas = this.barChartTarget;
      canvas.width = canvas.scrollWidth;
      canvas.height = canvas.scrollHeight;
      const ctx = canvas.getContext('2d');

      const data = this.barChartDataTargets;
      const padding = 30;
      
      // Get Max Value
      const expresion = /^\w{1}:\s{1}(\d+)/
      let maxValue = 0;
      data.forEach((ranking) => {
        for(let i=1;i<ranking.getElementsByTagName("li").length;i++){
          maxValue = Math.max(maxValue, ranking.getElementsByTagName("li")[i].innerHTML.match(expresion)[1]);
        }
      })
      
      // Redimension to Add Padding
      const canvasActualHeight = canvas.height - padding * 2;
      const canvasActualWidth = canvas.width - padding * 2;
    
      // For each ranking
      let barIndex = 0;
      let spaceBetweenRankings = 0;
      const barSize = canvasActualWidth / ((data.length * 2) + (data.length - 1));
      

      data.forEach((ranking) => {
        // Structure Data
        let seriesData = {
          "victory": ranking.getElementsByTagName("li")[1].innerHTML.match(expresion)[1],
          "defeat": ranking.getElementsByTagName("li")[2].innerHTML.match(expresion)[1]
        };

        // Draw the Bars
        for (let categ in seriesData){
            var val = seriesData[categ];
            var barHeight = Math.round(canvasActualHeight * val/maxValue);

            if (barHeight == 0) {
              barHeight = 1;
            }

            this.drawBar(
                ctx,
                padding + spaceBetweenRankings + barIndex * barSize,
                canvas.height - barHeight - padding,
                barSize,
                barHeight,
                colors[barIndex%colors.length]
            );
              
            // Bar Number on Top
            ctx.save();
            ctx.textBaseline="bottom";
            ctx.textAlign="center";
            ctx.fillStyle = this.fontColor;
            ctx.font = "bold 20px Work Sans";
            ctx.fillText(ranking.getElementsByTagName("li")[(barIndex%colors.length)+1].innerHTML.match(expresion)[1], padding + spaceBetweenRankings + barIndex * barSize + barSize/2, canvas.height - barHeight - padding);
            ctx.restore();  

            barIndex++;
        }

        // Draw series name
        ctx.save();
        ctx.textBaseline="bottom";
        ctx.textAlign="center";
        ctx.fillStyle = this.fontColor;
        ctx.font = "bold 20px Work Sans";
        ctx.fillText(ranking.getElementsByTagName("li")[0].innerHTML, padding + spaceBetweenRankings + (barIndex-1) * barSize, canvas.height);
        ctx.restore();  

        spaceBetweenRankings+=barSize;
      })

    }

    drawBar(ctx, upperLeftCornerX, upperLeftCornerY, width, height,color){
      ctx.save();
      ctx.fillStyle=color;
      ctx.fillRect(upperLeftCornerX,upperLeftCornerY,width,height);
      ctx.restore();
    }

    drawWinLossesCharts(){
      const canvases = this.winsLossesTargets;
      canvases.forEach((canvas) => {
        const ratio = Math.ceil(window.devicePixelRatio)
        canvas.width = canvas.scrollWidth * ratio;
        canvas.height = canvas.scrollHeight * ratio;
        let ctx = canvas.getContext('2d');
        let values=[parseInt(canvas.nextElementSibling.lastElementChild.innerHTML.replace('%', '')),
                    parseInt(canvas.previousElementSibling.lastElementChild.innerHTML.replace('%', ''))];
        let arcWidth= canvas.width/7;
        this.drawDonutChart(ctx, canvas.height/2, canvas.width/2, canvas.width/2 - arcWidth, arcWidth,values);
      })
    }

    drawDonutChart(ctx, cx,cy,radius,arcwidth,values){
      let tot=0;
      let accum=0;
      const PI=Math.PI;
      const PI2=PI*2;
      const offset=-PI/2;
      ctx.lineWidth=arcwidth;
      for(var i=0;i<values.length;i++){tot+=values[i];}
      for(var i=0;i<values.length;i++){
          ctx.beginPath();
          ctx.arc(cx,cy,radius,
              offset+PI2*(accum/tot),
              offset+PI2*((accum+values[i])/tot)
          );
          ctx.strokeStyle=this.colors[i];
          ctx.stroke();
          accum+=values[i];
      }
  }
}