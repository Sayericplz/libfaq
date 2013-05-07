class DmsController < ApplicationController
  def index
  	session[:q] = ""
    session[:a] = 0
    session[:b] = 0
    session[:frontpage]=1
  	@faqs = []
    #@faqs.sort!{ |a,b| b.questiondate <=> a.questiondate } 
    session[:frontsize]=@faqs.size
    session[:frontpages] = session[:frontsize]/5
    if session[:frontsize] > session[:frontpages]*5
      session[:frontpages] = session[:frontpages]+1
    end
  end

  def search
    session[:q] = params[:question]
    session[:frontpage]=1
  	@faqs = sift()
    @faqs = @faqs[(session[:frontpage]-1)*5,5]
    if @faqs.size == 0
      flash[:notice]="none"
      redirect_to :action => :index
    else
      render :index
    end
  end

  def show
  	@faq = Faq.find(params[:id])
    @faq.hit += 1
    @faq.save
    @faq
  end

  def ask
  	@faq = Faq.find(params[:id])
    @faq.hit += 1
    @faq.save
    render :show
  end

  def new
    session[:a]=rand(9)
    session[:b]=rand(9)
    @captcha = "#{session[:a]}+#{session[:b]}="
  end

  def create
    if session[:a]+session[:b] != params[:answer].to_i
      redirect_to :back,:notice => "error1"
    elsif params[:question].blank?
      redirect_to :back,:notice => "error2"
    elsif params[:phone].blank?
      redirect_to :back,:notice => "error3"     
    else
    	@faq = Faq.new
    	@faq.hit = 1
    	@faq.keywords = params[:keywords]
    	@faq.question = params[:question]+"(From:{name:"+params[:name]+",department:"+params[:department]+",phone:"+params[:phone]+"})"
    	@faq.questiondate = Time.now
    	@faq.enable = false
    	if @faq.save
        flash[:notice]="success"
    		redirect_to :action=>:index
    	else
    		redirect_to :back,:notice => "error4"
    	end
    end
  end

  def prompt
    @faq = []
    Faq.all.each do |f|
      if f.enable==true and (f.question.include? params[:term] or f.keywords.include? params[:term])
        @faq << f
      end
    end
    @faq.sort!{ |a,b| b.hit <=> a.hit } 
    @faq = @faq[0,10]
    respond_to do |format|
      format.json { render :json => @faq.to_json(:only => [:question ,:hit]) }
    end
  end

  def firstpage
    session[:frontpage]=1
    redirect_to :action=>'changepage'
  end

  def prepage
    if session[:frontpage] != 1
      session[:frontpage] = session[:frontpage] - 1
    end
    redirect_to :action=>'changepage'  
  end

  def nextpage
    if session[:frontpage] != session[:frontpages]
      session[:frontpage] = session[:frontpage] + 1
    end
    redirect_to :action=>'changepage'
  end

  def lastpage
    session[:frontpage]=session[:frontpages]
    redirect_to :action=>'changepage'
  end

  def inputpage
    if !params[:pagenum].blank?
      if params[:pagenum].to_i >= 1 and params[:pagenum].to_i <=session[:frontpages]
        session[:frontpage]=params[:pagenum].to_i
      end 
    end
    redirect_to :action=>'changepage'
  end

  def changepage
    @faqs = sift()
    @faqs = @faqs[(session[:frontpage]-1)*5,5]
    render :index
  end

  def sift
    @faqs = []
    unless session[:q].blank?
      Faq.all.each do |f|
        if f.enable==true and (f.question.include? session[:q] or f.keywords.include? session[:q])
          @faqs << f
        end
      end
    end
    @faqs.sort!{ |a,b| b.hit <=> a.hit }
    session[:frontsize]=@faqs.size
    session[:frontpages] = session[:frontsize]/5
    if session[:frontsize] > session[:frontpages]*5
      session[:frontpages] = session[:frontpages]+1
    end
    @faqs
  end 
end
