class FaqsController < ApplicationController
  # GET /faqs
  # GET /faqs.json
  @@nperpage=15

  before_filter :require_login
  def require_login
    if session[:current_user].nil?
     redirect_to :controller=>"home"
    end
  end

  def index
    session[:firstDate]=''
    session[:secondDate]=''
    session[:keywords]=''
    session[:question]=''
    session[:backpage]=1
    if session[:enabled].nil?
      session[:enabled] = true
    end
    if session[:disabled].nil?
      session[:disabled] = true
    end
    if session[:enabled] == true and session[:disabled] == true
      @faqs = Faq.all
    elsif session[:enabled] == true
      @faqs = Faq.where('enable=true')
    elsif session[:disabled] == true
      @faqs = Faq.where('enable=false')
    else
      @faqs = []
    end
    @faqs.sort!{ |a,b| b.questiondate <=> a.questiondate } 
    session[:backsize]=@faqs.size
    session[:backpages] = session[:backsize]/15
    if session[:backsize] > session[:backpages]*15
      session[:backpages] = session[:backpages]+1
    end
    @faqs=@faqs[0,15]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @faqs }
    end
  end

  # GET /faqs/1
  # GET /faqs/1.json
  def show
    @faq = Faq.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @faq }
    end
  end

  # GET /faqs/new
  # GET /faqs/new.json
  def new
    @faq = Faq.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @faq }
    end
  end

  # GET /faqs/1/edit
  def edit
    @faq = Faq.find(params[:id])
  end

  # POST /faqs
  # POST /faqs.json
  def create
    @faq = Faq.new(params[:faq])
    if params[:answer].nil?
      @faq.answerdate = nil
    end
    @faq.checkperson = session[:current_user]
    @faq.checkdate = Time.now
    respond_to do |format|
      if @faq.save
        format.html { redirect_to @faq, notice: 'Faq was successfully created.' }
        format.json { render json: @faq, status: :created, location: @faq }
      else
        format.html { render action: "new" }
        format.json { render json: @faq.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /faqs/1
  # PUT /faqs/1.json
  def update
    @faq = Faq.find(params[:id])
    if params[:answer].nil?
      @faq.answerdate = nil
    end
    @faq.checkperson = session[:current_user]
    @faq.checkdate = Time.now
    respond_to do |format|
      if @faq.update_attributes(params[:faq])
        format.html { redirect_to @faq, notice: 'Faq was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @faq.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /faqs/1
  # DELETE /faqs/1.json
  def destroy
    @faq = Faq.find(params[:id])
    @faq.destroy
    respond_to do |format|
      format.html { redirect_to changepage_faqs_path }
    end
  end

  def sift
    if params[:enabled_box]=='1'
      session[:enabled] = true
    else
      session[:enabled] = false
    end
    if params[:disabled_box]=='1'
      session[:disabled] = true
    else
      session[:disabled] = false
    end
    session[:firstDate] = params[:firstDate]
    session[:secondDate] = params[:secondDate]
    session[:keywords] = params[:keywords]
    session[:question] = params[:question]
    session[:backpage] = 1
    @faqs=search()
    @faqs=@faqs[0,15]
    render :index
  end

  def firstpage
    session[:backpage]=1
    redirect_to changepage_faqs_path
  end

  def prepage
    if session[:backpage] != 1
      session[:backpage] = session[:backpage] - 1
    end
    redirect_to changepage_faqs_path  
  end

  def nextpage
    if session[:backpage] != session[:backpages]
      session[:backpage] = session[:backpage] + 1
    end
    redirect_to changepage_faqs_path
  end

  def lastpage
    session[:backpage]=session[:backpages]
    redirect_to changepage_faqs_path
  end

  def inputpage
    if !params[:pagenum].blank?
      if params[:pagenum].to_i >= 1 and params[:pagenum].to_i <=session[:backpages]
        session[:backpage]=params[:pagenum].to_i
      end 
    end
    redirect_to changepage_faqs_path
  end

  def changepage
    @faqs = search()
    @faqs = @faqs[(session[:backpage]-1)*15,15]
    render :index
  end

  def search
    if session[:enabled] == true and session[:disabled] == true
      @faqs = Faq.all
    elsif session[:enabled] == true
      @faqs = Faq.where('enable=true')
    elsif session[:disabled] == true
      @faqs = Faq.where('enable=false')
    else
      @faqs = []
    end  
    unless session[:firstDate].blank?
       @faqs.delete_if{|f|
          f.questiondate < session[:firstDate]
       }
    end   
    unless session[:secondDate].blank?      
       @faqs.delete_if{|f|
          f.questiondate > session[:secondDate]
       }
    end    
    unless session[:keywords].blank?      
       @faqs.delete_if{|f|
          !f.keywords.include?(session[:keywords])
       }
    end     
    unless session[:question].blank?      
       @faqs.delete_if{|f|
          !f.question.include?(session[:question])
       }
    end
    @faqs.sort!{ |a,b| b.questiondate <=> a.questiondate }
    session[:backsize]=@faqs.size
    session[:backpages] = session[:backsize]/15
    if session[:backsize] > session[:backpages]*15
      session[:backpages] = session[:backpages]+1
    end
    @faqs
  end 

  def stats
    /@records = Record.select('faq_id,sum(count) as total')
              .group('faq_id')
              .order('sum(count) DESC')
    @records = Faq.joins(:records).group('faqs.id').order('sum(count) DESC')/

    session[:firstDate2] = ''
    session[:secondDate2] = ''
    session[:backpage2] = 1

    sql = 'SELECT faqs.id as id, faqs.question as question, SUM(records.count) as total
          FROM faqs 
          JOIN records ON faqs.id = records.faq_id  
          GROUP BY faqs.id
          ORDER BY SUM(records.count) DESC'
    @records = Faq.find_by_sql(sql)
    session[:backsize2] = @records.size
    session[:backpages2] = @records.size / 15
    if session[:backsize2] > session[:backpages2]*15
      session[:backpages2] = session[:backpages2]+1
    end
    @records = @records[0,15]
    render :stats
  end

  def sift2
    session[:firstDate2] = params[:firstDate2]
    session[:secondDate2] = params[:secondDate2]
    session[:backpage2] = 1
    @records = search2()
    @records = @records[0,15]
    render :stats
  end

  def search2
    time1 = '1990-01-01'
    time2 = '2100-12-31' 
    unless session[:firstDate2].blank?
      time1 = session[:firstDate2]
    end   
    unless session[:secondDate2].blank?
      time2 = session[:secondDate2]
    end
    sql = "SELECT faqs.id as id, faqs.question as question, SUM(records.count) as total
          FROM records 
          JOIN faqs ON faqs.id = records.faq_id           
          WHERE records.thedate >='"+time1+"' and records.thedate <='"+time2+"'  
          GROUP BY records.faq_id
          ORDER BY SUM(records.count) DESC"
    @records = Faq.find_by_sql(sql)
    session[:backsize2] = @records.size
    session[:backpages2] = session[:backsize2]/15
    if session[:backsize2] > session[:backpages2]*15
      session[:backpages2] = session[:backpages2]+1
    end
    @records
  end 

  def firstpage2
    session[:backpage2]=1
    redirect_to changepage2_faqs_path
  end

  def prepage2
    if session[:backpage2] != 1
      session[:backpage2] = session[:backpage2] - 1
    end
    redirect_to changepage2_faqs_path  
  end

  def nextpage2
    if session[:backpage2] != session[:backpages2]
      session[:backpage2] = session[:backpage2] + 1
    end
    redirect_to changepage2_faqs_path
  end

  def lastpage2
    session[:backpage2]=session[:backpages2]
    redirect_to changepage2_faqs_path
  end

  def inputpage2
    if !params[:pagenum].blank?
      if params[:pagenum].to_i >= 1 and params[:pagenum].to_i <=session[:backpages2]
        session[:backpage2]=params[:pagenum].to_i
      end 
    end
    redirect_to changepage2_faqs_path
  end

  def changepage2
    @records = search2()
    @records = @records[(session[:backpage2]-1)*15,15]
    render :stats
  end
end
