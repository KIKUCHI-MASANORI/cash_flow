class HomeController < ApplicationController
# require "Test"
require "Date"
require 'bigdecimal'
protect_from_forgery except: :search # searchアクションを除外
#(https://qiita.com/ayacai115/items/ec7a621ec73692065d7a)参考
# include Test
#初回キャッシュフロー以降のページでリロードするとクラス変数の値消える。

  def top
  end

  def input_cash_data
  end

  def flow
    # out_puthoge                    = params[:hoge]
    # # @hoge = test
    # before_action :test

    if params[:age] === "" or  params[:after_years] === ""
      flash[:notice] = "*部分の入力は必須です"
      redirect_to("/input_cash_data")
    elsif params[:age] === "0" or params[:cost_of_other] === "0"
      flash[:notice] = "0以上の値を入力してください"
      redirect_to("/input_cash_data")
    elsif params[:age] !~ /\d/ or
          params[:income] !~ /\d/ or
          params[:income_spouse] !~ /\d/ or
          params[:asset] !~ /\d/ or
          params[:cost_of_living] !~ /\d/ or
          params[:cost_of_house] !~ /\d/ or
          params[:cost_of_auto] !~ /\d/ or
          params[:cost_of_insurance] !~ /\d/ or
          params[:cost_of_other] !~ /\d/ or
          params[:after_years] !~ /\d/
      flash[:notice] = "数字を入れてください"
      redirect_to("/input_cash_data")
    else
      # 年数表示
      after_years            = params[:after_years]
      after_years            = after_years.to_i
      @after_years           = after_years + 1

      #経過年数表示
      years                  = Date.today
      @years                 = years.year
      #年齢
      age                    = params[:age]
      age                    = age.to_i
      @age                   =[]

      #収入
      income                 = params[:income]
      income                 = income.to_f
      @income                =[]
      # 配偶者の収入
      income_spouse          =params[:income_spouse]
      income_spouse          =income_spouse.to_f
      @income_spouse         =[]
      #収入合計
      @income_sum            =[]

      #基本生活費
      cost_of_living         = params[:cost_of_living]
      cost_of_living         = cost_of_living.to_f
      @cost_of_living        =[]
      #住居関連費
      cost_of_house          = params[:cost_of_house]
      @cost_of_house         = cost_of_house.to_i
      #車両費
      cost_of_auto           = params[:cost_of_auto]
      cost_of_auto           = cost_of_auto.to_f
      @cost_of_auto          =[]
      #保険料
      cost_of_insurance      = params[:cost_of_insurance]
      cost_of_insurance      = cost_of_insurance.to_f
      @cost_of_insurance     =[]
      #その他支出
      cost_of_other          = params[:cost_of_other]
      cost_of_other          = cost_of_other.to_f
      @cost_of_other         =[]
      #支出合計
      @spending_sum          =[]
      #年間支出
      @years_spending        =[]

      #貯蓄残高
      asset                  = params[:asset]
      asset                  = asset.to_f
      @asset                 = []

      #計算前に退避
      @@age_initial                     = age
      @@income_initial                  = income
      @@income_spouse_initial           = income_spouse
      @@cost_of_living_initial          = cost_of_living
      @@cost_of_house                   = cost_of_house.to_i
      @@cost_of_auto_initial            = cost_of_auto
      @@cost_of_insurance_initial       = cost_of_insurance
      @@cost_of_other_initial           = cost_of_other
      @@asset_initial                   = asset


      #キャッシュフロー表表示ビューに送るための各項目リスト作成
      @after_years.times do |count|
        if count === 0
          @age.push(age + count)
          if age + count > 65
              @income.push(77)
              @income_spouse.push(77)
              @income_sum.push(77*2)
            else
              @income.push(income.round)
              @income_spouse.push(income_spouse.round)
              income_sum =
                            income.round        +
                            income_spouse.round
              @income_sum.push(income_sum)
          end
          #初回は変動率なし
          @cost_of_living.push(cost_of_living.round)
          @cost_of_auto.push(cost_of_auto.round)
          @cost_of_insurance.push(cost_of_insurance.round)
          @cost_of_other.push(cost_of_other.round)
          #支出合計算出
          spending_sum =
                         cost_of_living.round    +
                         cost_of_auto.round      +
                         cost_of_insurance.round +
                         cost_of_other.round     +
                         @cost_of_house
          @spending_sum.push(spending_sum)
          #年間支出 = 収入 - 支出合計算出
          years_spending = income.round + income_spouse.round - spending_sum
          @years_spending.push(years_spending.round)
          #count=0のときの貯蓄残高は入力値反映なので何もしない
          @asset.push(asset.round)
        else
          @age.push(age + count)
          #変動率の分を加算したものを各項目の配列にpush
          if age + count >=  65
              @income.push(77)
              @income_spouse.push(77)
              @income_sum.push(77*2)
            else
              income              = income * (1.01 ** count)
              income_spouse       = income_spouse * (1.01 ** count)
              @income.push(income.round)
              @income_spouse.push(income_spouse.round)
              income_sum =
                            income.round        +
                            income_spouse.round
              @income_sum.push(income_sum)
          end
          cost_of_living          = cost_of_living * (1.01 ** count)
          @cost_of_living.push(cost_of_living.round)
          cost_of_auto            = cost_of_auto * (1.01 ** count)
          @cost_of_auto.push(cost_of_auto.round)
          cost_of_insurance       = cost_of_insurance * (1.01 ** count)
          @cost_of_insurance.push(cost_of_insurance.round)
          cost_of_other           = cost_of_other * (1.01 ** count)
          @cost_of_other.push(cost_of_other.round)
          #支出合計算出
          spending_sum =
                         cost_of_living.round    +
                         cost_of_auto.round      +
                         cost_of_insurance.round +
                         cost_of_other.round     +
                         @cost_of_house
          @spending_sum.push(spending_sum)
          #年間支出 = 収入 - 支出合計算出
          years_spending = income.round + income_spouse.round - spending_sum
          @years_spending.push(years_spending.round)
          #貯蓄残高
          asset *= 1.01
          asset += years_spending
          @asset.push(asset.round)
        #if countのend
        end
      #@after_years.timesのend
      end
      #入力チェックのend

    end

    #教育費換算のために値退避
    @@after_years             =  @after_years
    @@years                   =  @years
    @@age                     =  @age
  #def flowのend
  end

  def number_of_children
  end

  def educational_expenses
  end

  def child_rearing
    @age              = @@age
    @@select_expenses = params[:select_expenses]
    @@select_expenses = @@select_expenses.to_i
  end

  def add_educational_expenses_flow

      #課題:POST→POSTでredirect_toは不可
      # render("/child_rearing")

      start_age                    = params[:start_age]
      @start_age                   = start_age.to_i

      #初回INPUTを取得
      @after_years                 =  @@after_years
      @years                       =  @@years
      age_initial                  =  @@age_initial
      @age                         =  @@age
      income_initial               =  @@income_initial
      income_spouse_initial        =  @@income_spouse_initial
      cost_of_living_initial       =  @@cost_of_living_initial
      @cost_of_house               =  @@cost_of_house
      cost_of_auto_initial         =  @@cost_of_auto_initial
      cost_of_insurance_initial    =  @@cost_of_insurance_initial
      cost_of_other_initial        =  @@cost_of_other_initial
      asset_initial                =  @@asset_initial

      @spllit_educational_expenses = []
      @life_event                  = []
      start_education              =  @start_age - @age[0]
      case @@select_expenses
      #配列に教育費を入れたらもうちょっとマシになる？
      when 782
        @life_event[start_education]                     = "第一子誕生"
        @spllit_educational_expenses[start_education+4]  = 21
        @life_event[start_education+4]                   = "幼稚園入学"
        @spllit_educational_expenses[start_education+5]  = 21
        @spllit_educational_expenses[start_education+6]  = 26
        @spllit_educational_expenses[start_education+7]  = 34
        @life_event[start_education+7]                   = "小学校入学"
        @spllit_educational_expenses[start_education+8]  = 27
        @spllit_educational_expenses[start_education+9]  = 28
        @spllit_educational_expenses[start_education+10] = 31
        @spllit_educational_expenses[start_education+11] = 34
        @spllit_educational_expenses[start_education+12] = 37
        @spllit_educational_expenses[start_education+13] = 46
        @life_event[start_education+13]                   = "中学校入学"
        @spllit_educational_expenses[start_education+14] = 39
        @spllit_educational_expenses[start_education+15] = 57
        @spllit_educational_expenses[start_education+16] = 51
        @life_event[start_education+16]                   = "高校入学"
        @spllit_educational_expenses[start_education+17] = 47
        @spllit_educational_expenses[start_education+18] = 36
        @spllit_educational_expenses[start_education+19] = 81
        @life_event[start_education+19]                   = "大校入学"
        @spllit_educational_expenses[start_education+20] = 53
        @spllit_educational_expenses[start_education+21] = 53
        @spllit_educational_expenses[start_education+22] = 53
      when 930
        @life_event[start_education]                     = "第一子誕生"
        @spllit_educational_expenses[start_education+4]  = 21
        @life_event[start_education+4]                   = "幼稚園入学"
        @spllit_educational_expenses[start_education+5]  = 21
        @spllit_educational_expenses[start_education+6]  = 26
        @spllit_educational_expenses[start_education+7]  = 34
        @life_event[start_education+7]                   = "小学校入学"
        @spllit_educational_expenses[start_education+8]  = 27
        @spllit_educational_expenses[start_education+9]  = 28
        @spllit_educational_expenses[start_education+10] = 31
        @spllit_educational_expenses[start_education+11] = 34
        @spllit_educational_expenses[start_education+12] = 37
        @spllit_educational_expenses[start_education+13] = 46
        @life_event[start_education+13]                   = "中学校入学"
        @spllit_educational_expenses[start_education+14] = 39
        @spllit_educational_expenses[start_education+15] = 57
        @spllit_educational_expenses[start_education+16] = 51
        @life_event[start_education+16]                   = "高校入学"
        @spllit_educational_expenses[start_education+17] = 47
        @spllit_educational_expenses[start_education+18] = 36
        @spllit_educational_expenses[start_education+19] = 115
        @life_event[start_education+19]                   = "大校入学"
        @spllit_educational_expenses[start_education+20] = 91
        @spllit_educational_expenses[start_education+21] = 91
        @spllit_educational_expenses[start_education+22] = 91
      when 1105
        @life_event[start_education]                     = "第一子誕生"
        @spllit_educational_expenses[start_education+4]  = 21
        @life_event[start_education+4]                   = "幼稚園入学"
        @spllit_educational_expenses[start_education+5]  = 21
        @spllit_educational_expenses[start_education+6]  = 26
        @spllit_educational_expenses[start_education+7]  = 34
        @life_event[start_education+7]                   = "小学校入学"
        @spllit_educational_expenses[start_education+8]  = 27
        @spllit_educational_expenses[start_education+9]  = 28
        @spllit_educational_expenses[start_education+10] = 31
        @spllit_educational_expenses[start_education+11] = 34
        @spllit_educational_expenses[start_education+12] = 37
        @spllit_educational_expenses[start_education+13] = 46
        @spllit_educational_expenses[start_education+14] = 39
        @spllit_educational_expenses[start_education+15] = 57
        @spllit_educational_expenses[start_education+16] = 127
        @life_event[start_education+16]                   = "高校入学"
        @spllit_educational_expenses[start_education+17] = 97
        @spllit_educational_expenses[start_education+18] = 85
        @spllit_educational_expenses[start_education+19] = 115
        @life_event[start_education+19]                   = "大校入学"
        @spllit_educational_expenses[start_education+20] = 91
        @spllit_educational_expenses[start_education+21] = 91
        @spllit_educational_expenses[start_education+22] = 91
      when 1501
        @life_event[start_education]                     = "第一子誕生"
        @spllit_educational_expenses[start_education+4]  = 21
        @life_event[start_education+4]                   = "幼稚園入学"
        @spllit_educational_expenses[start_education+5]  = 21
        @spllit_educational_expenses[start_education+6]  = 26
        @spllit_educational_expenses[start_education+7]  = 34
        @life_event[start_education+7]                   = "小学校入学"
        @spllit_educational_expenses[start_education+8]  = 27
        @spllit_educational_expenses[start_education+9]  = 28
        @spllit_educational_expenses[start_education+10] = 31
        @spllit_educational_expenses[start_education+11] = 34
        @spllit_educational_expenses[start_education+12] = 37
        @spllit_educational_expenses[start_education+13] = 157
        @spllit_educational_expenses[start_education+14] = 115
        @spllit_educational_expenses[start_education+15] = 125
        @spllit_educational_expenses[start_education+16] = 127
        @life_event[start_education+16]                   = "高校入学"
        @spllit_educational_expenses[start_education+17] = 97
        @spllit_educational_expenses[start_education+18] = 85
        @spllit_educational_expenses[start_education+19] = 151
        @life_event[start_education+19]                   = "大校入学"
        @spllit_educational_expenses[start_education+20] = 126
        @spllit_educational_expenses[start_education+21] = 126
        @spllit_educational_expenses[start_education+22] = 126
      when 2224
        @life_event[start_education]                     = "第一子誕生"
        @spllit_educational_expenses[start_education+4]  = 21
        @life_event[start_education+4]                   = "幼稚園入学"
        @spllit_educational_expenses[start_education+5]  = 21
        @spllit_educational_expenses[start_education+6]  = 26
        @spllit_educational_expenses[start_education+7]  = 184
        @life_event[start_education+7]                   = "小学校入学"
        @spllit_educational_expenses[start_education+8]  = 127
        @spllit_educational_expenses[start_education+9]  = 136
        @spllit_educational_expenses[start_education+10] = 146
        @spllit_educational_expenses[start_education+11] = 155
        @spllit_educational_expenses[start_education+12] = 165
        @spllit_educational_expenses[start_education+13] = 157
        @spllit_educational_expenses[start_education+14] = 115
        @spllit_educational_expenses[start_education+15] = 125
        @spllit_educational_expenses[start_education+16] = 127
        @life_event[start_education+16]                   = "高校入学"
        @spllit_educational_expenses[start_education+17] = 97
        @spllit_educational_expenses[start_education+18] = 85
        @spllit_educational_expenses[start_education+19] = 151
        @life_event[start_education+19]                   = "大校入学"
        @spllit_educational_expenses[start_education+20] = 126
        @spllit_educational_expenses[start_education+21] = 126
        @spllit_educational_expenses[start_education+22] = 126
      end


      #全要素に教育費を入れたあとでstart_education+Nと@yearsを比較して@yearsよりはみ出たぶんを切る
      after_years = @after_years
      after_years = after_years.to_i
      if @spllit_educational_expenses.length - after_years > 0
        cut_arry_element = @spllit_educational_expenses.length - after_years
        @spllit_educational_expenses.slice!(after_years, cut_arry_element)
        @life_event.slice!(after_years, cut_arry_element)
        # @spending_sum.slice!(after_years, cut_arry_element)
      end

      @age                   =[]
      @income                =[]
      @income_spouse         =[]
      @income_sum            =[]
      @cost_of_living        =[]
      @cost_of_auto          =[]
      @cost_of_insurance     =[]
      @cost_of_other         =[]
      @spending_sum          =[]
      @years_spending        =[]
      @asset                 =[]

      #キャッシュフロー表表示ビューに送るための各項目リスト作成
      @after_years.times do |count|
        @spllit_educational_expenses[count] ||=0
        if count === 0
          @age.push(age_initial + count)
          if age_initial + count > 65
              @income.push(77)
              @income_spouse.push(77)
              @income_sum.push(77*2)
            else
              @income.push(income_initial.round)
              @income_spouse.push(income_spouse_initial.round)
              income_sum =
                            income_initial.round        +
                            income_spouse_initial.round
              @income_sum.push(income_sum)
          end
          #初回は変動率なし
          @cost_of_living.push(cost_of_living_initial.round)
          @cost_of_auto.push(cost_of_auto_initial.round)
          @cost_of_insurance.push(cost_of_insurance_initial.round)
          @cost_of_other.push(cost_of_other_initial.round)
          #支出合計算出
          spending_sum =
                         cost_of_living_initial.round    +
                         cost_of_auto_initial.round      +
                         cost_of_insurance_initial.round +
                         cost_of_other_initial.round     +
                         @cost_of_house                  +
                         @spllit_educational_expenses[count]
          @spending_sum.push(spending_sum)
          #年間支出 = 収入 - 支出合計算出
          years_spending = income_initial.round + income_spouse_initial.round - spending_sum
          @years_spending.push(years_spending.round)
          #貯蓄残高は入力値反映なので何もしない
          @asset.push(asset_initial.round)
        else
          @age.push(age_initial + count)
          #変動率の分を加算したものを各項目の配列にpush
          if age_initial + count >=  65
              @income.push(77)
              @income_spouse.push(77)
              @income_sum.push(77*2)
            else
              income_initial              = income_initial * (1.01 ** count)
              income_spouse_initial       = income_spouse_initial * (1.01 ** count)
              @income.push(income_initial.round)
              @income_spouse.push(income_spouse_initial.round)
              income_sum =
                            income_initial.round        +
                            income_spouse_initial.round
              @income_sum.push(income_sum)
          end


          cost_of_living_initial          = cost_of_living_initial * (1.01 ** count)
          @cost_of_living.push(cost_of_living_initial.round)
          cost_of_auto_initial           = cost_of_auto_initial * (1.01 ** count)
          @cost_of_auto.push(cost_of_auto_initial.round)
          cost_of_insurance_initial       = cost_of_insurance_initial * (1.01 ** count)
          @cost_of_insurance.push(cost_of_insurance_initial.round)
          cost_of_other_initial           = cost_of_other_initial * (1.01 ** count)
          @cost_of_other.push(cost_of_other_initial.round)
          #支出合計算出
          spending_sum =
                         cost_of_living_initial.round    +
                         cost_of_auto_initial.round      +
                         cost_of_insurance_initial.round +
                         cost_of_other_initial.round     +
                         @cost_of_house                  +
                         @spllit_educational_expenses[count]
          @spending_sum.push(spending_sum)
          #年間支出 = 収入 - 支出合計算出
          years_spending = income_initial.round + income_spouse_initial.round - spending_sum
          @years_spending.push(years_spending.round)
          #貯蓄残高
          asset_initial *= 1.01
          asset_initial += years_spending
          @asset.push(asset_initial.round)
        #if countのend
        end
      #@after_years.timesのend
      end

  end

end
