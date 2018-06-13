require 'sinatra'
require 'sinatra/reloader'
require 'csv'

get '/' do
    erb :index
end

get '/new' do
    erb :new
end

post '/create' do
    # 사용자가 입력한 정보를 받아서
    # CSV 파일 가장 마지막에 등록
    # => 이 글의 글번호도 같이 저장해야함
    # => 기존의 글 개수를 파악해서
    # => 글 개수 +1해서 저장
    title = params[:title]
    contents = params[:contents]
    id = CSV.read('./boards.csv').count + 1
    puts id 
    CSV.open('./boards.csv','a+') do |row|
        row << [id, title, contents]
    end
    redirect "/board/#{id}"
end

get '/boards' do
    # 파일을 읽기 모드로 열고
    # 각 줄마다 순회하면서
    # @가 붙어있는 변수에 넣어줌
    @boards = []
    CSV.open('./boards.csv', 'r+').each do |row|
        @boards << row  #한 줄씩 순회하면서 등록
    end
    erb :boards
end

get '/board/:id' do
    # CSV파일에서 params[:id]로 넘어온 친구와 같은 글번호를 가진 row를 선택
    # => CSV파일을 전체 순회합니다
    # => 순회하다가 첫번째 col이 id와 같은 값을 만나면 순회를 정지하고 
    # => 값을 변수에다가 담아줌
    @board = []
    CSV.read('./boards.csv').each do |row|
        if row[0].eql?(params[:id])
            @board = row
        break
        end
    end
  erb :board
end



get '/user/new' do
    erb :new_user
end

post '/user/create' do
    id = params[:id]
    password = params[:password]
    password_cf = params[:password_cf]
    if password.eql?(password_cf)
        user=[]
        CSV.read('./User.csv').each do |row|
            user << row[0]
        end
        unless user.include?(id)
            CSV.open('./User.csv','a+') do |row|
                row << [id, password]
            end
            redirect :"/user/#{id}"
        else
            # 아이디 중복 에러
            puts "error1"
            erb :error
        end
    else
        #비밀번호 비일치 에러
        puts "error2"
        erb :error
    end
end

get '/users' do
    @users = []
    CSV.open('./User.csv', 'r+').each do |row|
        @users << row
    end
    erb :users
end

get '/user/:id' do
    @user= []
    CSV.read('./User.csv').each do |row|
        if row[0].eql?(params[:id])
            @user = row
            break
        end
    end
    erb :user
end
