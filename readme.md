## 180612_Day5

#### 오늘 할 내용

- CRUD 중에서 CR을 할겁니다
- 자료가 저장되는 곳은 DB가 아니라 CSV파일로 저장합니다.
- 그리고 사용자의 입력을 받아서 간이 게시판은 만들겁니다.



#### 스스로 과제

- `bootstrap`을 사용할 수 있도록 CDN으로 추가해주세요.

- 사용자의 입력을 받는 `form`태그로 이루어진 `/new` 액션과 `erb`파일
  - `form`의 `action`속성은 `/create`로 가도록 합니다.
  - `method`는 `post`를 이용합니다.
  - 게시판 글의 제목(title)과 본문(contents) 두가지 속성을 저장할겁니다.
- 전체 목록을 보여주는 `table`태그로 이루어진 `/boards`액션과 `erb` 파일 



- `/create` 액션을 만들고 작성 후에는 `/boards` 액션으로 돌아가게 구성
  - (수정)`/create` 액션이 동작한 이후에는 본인이 작성한 글로 이동합니다.
- 각 글(1개의 글을 보는 페이지)을 볼 수 있는 페이지는 `/board/글번호` 의 형태로 작성합니다.

#### Create 와 Read

1. `get` /boards/new
2. `post` /boards/create
3. `get` /boards
4. `get` /board/:id

- `board`라고 하는 게시판이 하나만 존재하고 있다.
- `user`라고 하는 CRUD 기능을 해야하는 DB Table 만든다고 가정하면?
- 새로운 유저를 등록한다면?



### 강의내용

1. sinatra로 게시판 만들어보기
   - 프로젝트에 bootstrap 포함시키기(CDN)
   - [getbootstrap.com](https://getbootstrap.com)에서 필요한 부분 붙여넣어보기
2. CSV로 DBMS의 역할에 대해서 살펴보기
   - CSV column 구성하기
3. 기본 Create와 Read 구현해보기



## 1. 게시판의 역할 정의하기 및 bootstrap 활용하기

- 게시판은 단순히 제목과, 본문의 속성을 가진, CRUD를 필요로 하는 가장 기본적인 기능이다.
- CRUD란 `Create`, `Read`, `Update`, `Delete` 의 역할을 의미한다.
- 제목과 본문을 DB에 저장하고 필요에 따라 해당 부분을 불러오게 된다.
- 게시판 기능을 만들기 이전에 게시판 글 하나가 가져야할 속성을 정리해보자.

> 인덱싱을 위한 ID, 제목, 본문, 작성자 등이 있을 텐데 우리는 ID, 제목, 본문만 저장하고 구현해보자.
>
> 또한 조금 더 아름다운 view를 만들기 위해 bootstrap을 사용할 것이다.

- 코드에서 가장 중요한 부분중 하나는 반복되는 코드를 최소한으로 줄이는 것이다. 우리는 `<html>`, `<head>`, `<body>` 태그가 반복적으로 쓰이는 것을 막기위해 `layout`, 즉 틀을 지정할 것이다. 

```command
$ mkdir day4
$ mkdir day4/views
$ cd day4
$ touch app.rb && touch views/layout.erb
$ gem install 'sinatra'
$ gem install 'sinatra-reloader'
```

*views/layout.erb*

```html
<html>
    <head>
        <title>로보어드바이저 과정 화이팅</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" integrity="sha384-WskhaSGFgHYWDcbwN70/dfYBj47jz9qbsMId/iRN3ewGhXQFZCSftd1LZCfmhktB" crossorigin="anonymous">
        <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js" integrity="sha384-smHYKdLADwkXOn1EmN1qk/HfnUcbVRZyYmZ4qpPea6sjB/pTJ0euyQp0Mk8ck+5T" crossorigin="anonymous"></script>
    </head>
    <body>
        <%= yield %>
    </body>
</html>
```

*views/app.erb*

```html
<p>Hi!</p>
```

*app.rb*

```ruby
require 'sinatra'
require 'sinatra/reloader'

get '/' do
     erb :app
end
```

- `<%= yield %>` 라는 문법이 생소할 수 있다. 하지만 말그대로 '양보한다'는 의미로 코드의 진행과정을 양보한다라고 볼 수 있겠다. 우리가 반복을 원하는 코드 중에서 변경을 원하는 부분을 찾아 해당 위치를 지정해준다고 할 수 있겠다.
- `layout.erb` 파일을 활용하는 이유는 bootstrap을 활용하기 위해서 CDN코드를 활용해야 하는데 layout을 활용하지 않으면 이 코드가 계속해서 반복되게 된다. 이러한 반복을 막기위해 layout이라고 하는 '틀'을 활용하게 되는 것이다.



## 2. CSV를 통해 DB구조에 대해 살펴보자

- DB를 사용하는 가장 근본적인 이유는 정보를 **영구적으로** 저장하기 위해서 이다. 만약 서버가 다운된다고 해서 작성했던 모든 정보가 삭제된다면, 회원정보, 결제정보 등 많은 중요한 정보를 매 순간 날려먹을 수도 있다는 불안함 속에 살아야 할 것이다.
- CSV파일을 활용하는 이유는 DB와 가장 유사하다고 할 수 있기 때문이다. 우리가 가장 가깝게, 자주 활용하던 DBMS가 바로 excel이다. 컬럼에 속성을 지정하고 그 속성에 맞춰 1줄씩 데이터를 추가하고, 원하는 데이터를 조회하고, 수정, 삭제하는 것이 바로 DBMS가 하는 역할이다.
- CSV를 활용하기 위해서 `gem install csv` 를 먼저 진행한다.

```ruby
require 'sinatra'
require 'sinatra/reloader'
require 'csv'
...
```

- 이제 우리의 프로젝트에서 CSV 라이브러리를 활용할 수 있다.

> 본격적으로 Create와. Read에 대해서 배우기 이전에 WildCard Parameter에 대해서 알고가자.
>
> 활용 형태는 다음과 같다.
>
> ```ruby
> get '/index/:id' do
> params[:id]
>     ...
> end
> ```
>
> 기존에 사용해왔던 Parameter와는 다르게 url자체에 파라미터를 받을 수 있다. 우리가 활용하는 Github도 내 계정에 접속했을 때 처음 접근하는 url이 `https://github.com/lovings2u`로 구성되어 있는데 여기서 우리의 계정명이 하나의 파라미터로 활용되는 것이라고 볼 수 있겠다. 이는 [일부 블로그 사이트](https://medium.com/s/story/why-breakups-hurt-like-hell-5edcd3777a46) 등에서도 발견할 수 있다. 물론 동일한 제목일 경우 중첩이 될 수 있기 때문에 이를 구분할 id를 추가하는 것이 중요하다.

- CSV는 다음과 같은 형태로 되어 있다.

```csv
1,title1,contents1
2,title2,contents2
3,title3,contents3
4,title4,contents4
...
```

- 각 한줄은 row라고 하고 하나의 ,(comma)는 하나의 컬럼을 의미한다. 한 줄은 하나의 데이터를 의미하고 하나의 세로선은 하나의 속성을 의미한다.
- 오늘 배울 내용은 `Create` 와 `Read`에 대해서 배울 건데 각각의 액션을 먼저 정의 해보자.
  - 모든 글을 보여줄 인덱스 페이지는 `/index`
  - 하나의 글을 보여줄 페이지는 `/show/글번호`
  - 새 글을 등록할 페이지는 `/new`
  - 실제로 글을 등록할 곳은 `/create`

## 3. Index 와 Show

- 아직 우리가 직접 데이터를 등록하는 것은 불가능 하지만 직접 CSV파일을 작성하는 것은 가능하다. 일단 직접 CSV파일을 작성하고 그 이후에 Create에 대해 배워보자
- CSV 라이브러리가 가지고 있는 메소드에 대해서는 [다음](https://ruby-doc.org/stdlib-2.0.0/libdoc/csv/rdoc/CSV.html) 에서 확인할 수 있다.

*views/index.erb*

```html
<table class="table">
    <thead>
        <th>글번호</th>
        <th>제목</th>
        <th></th>
    </thead>
    <tbody>
        <% @boards.each do |board| %>
        <tr>
            <td><%= board[0] %></td>
            <td><%= board[1] %></td>
            <td><a href="/boards/<%= board[0] %>">글보기</a></td>
        </tr>
        <% end %>
    </tbody>
</table>
```

*app.rb*

```ruby
...
get '/index' do
    @boards = []
    CSV.foreach('app.csv') do |row|
        @boards << row
    end
    erb :index
end
...
```

*app.csv*

```csv
1,title1,contents1
2,title2,contents2
3,title3,contents3
4,title4,contents4
```

- CSV에 등록되어 있는 모든 글을 `@boards`라고 하는 배열에 저장하고 배열의 각 요소를 순회하며 글번호, 제목, 본문을 출력한다.
- 하나의 글을 조회할 때에는 `/show/글번호` 형태의 url을 사용한다. 이를 위해서는 위에서 간략히 살펴봤던 WildCard를 활용하도록 한다.

*views/show.erb*

```html
<h1>제목: <%= @board[1] %></h1>
<p>본문: <%= @board[2] %></p>
```

*app.rb*

```ruby
get '/boards/:id' do
    @board = []
    CSV.foreach('app.csv') do |row|
        @board = row if row[0].eql?(params[:id])
    end
    erb :show
end
```

- DBMS에서 하나의 글을 조회할 때에는 기본적으로 Btree Search를 이용한다. 하지만 우리는 적은 개수의 데이터만 가지고 테스트 할 예정이기 때문에 전체조회를 활용한다.
- 전체를 조회하다가 사용자가 원하는 글번호에 해당하는 row를 만나면 해당 줄을 `@board` 변수에 값을 저장한다.
- 저장한 값을 `show.erb` 에서 보여준다.



## 4. New와 Create

- 새 글을 등록할 때에는 먼저 사용자로부터 내용을 받을 페이지가 필요하다. 그리고 사용자가 입력한 정보를 바탕으로 새로운 액션에서 저장하고 `show` 페이지나 `index` 페이지로 리디렉션을 발생시킨다.

*views/new*

```html
<form action="/create" method="POST">
    <input type="text" name="title" placeholder="제목"><br>
    <textarea name="contents" row="4" column="10" placeholder="본문"></textarea>
    <input type="submit" value="작성">
</form>
```

*app.rb*

```ruby
get '/new' do
    erb :new
end

post '/create' do
    index = CSV.read('app.csv').size
    CSV.open('app.csv', 'a+') do |row|
        row << [index+1,params[:title], params[:contents]]
    end
    redirect "/index"
end
```

- 새로운 정보를 등록하는 페이지에는 기타 로직이 필요하지 않다. 현재는 그러하다.
- 사용자는 작성이 완료되어 form을 submit하면 `/create` 액션에 `POST` method로 요청을 보내게 된다. 
- 새 글을 등록할 때에는 해당 글이 몇번째 글로 등록될 것인지 확인하기 위해 현재까지 등록된 글의 개수를 파악하고 그 숫자에 1을 더해 새 글을 등록하게 된다.





### 스스로 과제

- `User`를 등록할 수 있는 CSV 파일을 만들거에요
- id, password, password_confirmation
- 조건 1
  - password와 password_confirmation 을 받는데 회원을 등록할 때 이 두 문자열이 다르면 회원 등록안됨
- Route(라우팅)
  - `get` /user/new => new_user.erb
  - `post` /user/create 
  - `get` /users => users.erb
  - `get` /user/:id => user.erb

##### 추가과제

- 이미 존재하는 회원일 때에도 `error` 페이지로 이동



## Rails

#### gem install bundler

- `bundler `라는 친구는 내 프로젝트에 사용될 모든 잼을 설치해줌
- 내가 사용하는 잼은 `Gemfile`에 명시한다.
- `Gemfile`에 내가 사용할 잼을 명시한 이후에 터미널에 다음 명령어를 입력한다.

```command
$ bundle install
```

- 사용할 라이브러리를 추가한 이후에도 반드시 해당 명령어를 실행한다.
- 사용하지 않게 된 라이브러리는`Gemfile`에서 삭제한 이후에 위 명령어를 실행한다.
- 

