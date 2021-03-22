import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['winsLosses'];

    connect() {
      this.colors=['#FBEC51', '#0091D2'];
      const canvases = this.winsLossesTargets;
      canvases.forEach((canvas) => {
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