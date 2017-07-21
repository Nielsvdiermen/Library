pragma solidity ^0.4.11;

contract DateTimeAPI {
        /*
         *  Abstract contract for interfacing with the DateTime contract.
         *
         */
        function isLeapYear(uint16 year) constant returns (bool);
        function getYear(uint timestamp) constant returns (uint16);
        function getMonth(uint timestamp) constant returns (uint8);
        function getDay(uint timestamp) constant returns (uint8);
        function getHour(uint timestamp) constant returns (uint8);
        function getMinute(uint timestamp) constant returns (uint8);
        function getSecond(uint timestamp) constant returns (uint8);
        function getWeekday(uint timestamp) constant returns (uint8);
        function toTimestamp(uint16 year, uint8 month, uint8 day) constant returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) constant returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) constant returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) constant returns (uint timestamp);
}

contract BookLibrary { 

	DateTimeAPI datetime = DateTimeAPI(0x2F99c39d0f8D199e0Ad2EEbDEf4b876a453911D4);

	struct review{
			address	user;
			uint stars;
			bytes32 review;
		}

	struct book{
		bytes32 name;
		bytes32 writer;
		address currentRenter;
		uint rentDate; //timestamp
		uint returnDate; //timestamp
		uint timesRented;
		review[] reviews;
		mapping (address => review) reviewInfo;
	}

	struct rentedBook{
			bytes32 name;
			uint rentedDay;
			uint returnedDay;
		}

	struct User{
		bytes32 name;
		uint8 currentBooks;
		rentedBook[] rentedBooks;
		mapping (bytes32 => rentedBook) rentedBookInfo;
	}

	bytes32[] bookList;
	bytes32[] userList;

	mapping (bytes32 => book) bookInfo;
	mapping (address => User) userInfo;

	function getCurrentBook(address user) internal constant returns(bytes32[],uint[],uint[]){
	  bytes32[] memory bookNameArray = new bytes32[](5);
		uint[] memory rentArray = new uint[](3);
		uint[] memory returnArray = new uint[](3);
		
		for(uint i=0;i<bookList.length;i++){
			if(bookInfo[bookList[i]].currentRenter == user){
				rentArray[0] = (datetime.getDay(bookInfo[bookList[i]].rentDate));
				rentArray[1] = (datetime.getMonth(bookInfo[bookList[i]].rentDate));
				rentArray[2] = (datetime.getYear(bookInfo[bookList[i]].rentDate));
				returnArray[0] = (datetime.getDay(bookInfo[bookList[i]].returnDate));
				returnArray[1] = (datetime.getMonth(bookInfo[bookList[i]].returnDate));
				returnArray[2] = (datetime.getYear(bookInfo[bookList[i]].returnDate));

				for (uint j=0;j<5;j++){
					if(bookNameArray[j] == ""){
						bookNameArray[j] = bookList[i];
						j = 5;
					}
				}
			}
		}

		return (bookNameArray,rentArray,returnArray);
	}

	function bookInformation(bytes32 bookName) constant returns(bytes32,bytes32,uint[],uint[]){
		bytes32 writer = bookInfo[bookName].writer;
		
		bytes32 currentRent = userInfo[bookInfo[bookName].currentRenter].name;

		uint[] memory rentArray = new uint[](3);
		rentArray[0] = (datetime.getDay(bookInfo[bookName].rentDate));
		rentArray[1] = (datetime.getMonth(bookInfo[bookName].rentDate));
	    rentArray[2] = (datetime.getYear(bookInfo[bookName].rentDate));

		uint[] memory returnArray = new uint[](3);
		returnArray[0] = (datetime.getDay(bookInfo[bookName].returnDate));
		returnArray[1] = (datetime.getMonth(bookInfo[bookName].returnDate));
		returnArray[2] = (datetime.getYear(bookInfo[bookName].returnDate));

		return (writer,currentRent,rentArray,returnArray);
	}

	function getBookReviews(bytes32 bookName) constant returns(uint[],bytes32[]){
		uint[] memory stars = new uint[](bookInfo[bookName].reviews.length);
		bytes32[] memory reviews = new bytes32[](bookInfo[bookName].reviews.length);

		for(uint i=0;i<bookInfo[bookName].reviews.length;i++){
			uint star = bookInfo[bookName].reviews[i].stars;
			bytes32 review = bookInfo[bookName].reviews[i].review;
			stars[i] = star;
			reviews[i] = review;
		}
		return(stars,reviews);
	}

	function getBooklist() constant returns(bytes32[],bytes32[]){
		bytes32[] memory bookL = new bytes32[](bookList.length);
		bytes32[] memory writerL = new bytes32[](bookList.length);

		for(uint i=0;i<bookList.length;i++){
			bytes32 bname = bookList[i];
			bytes32 bwriter = bookInfo[bname].writer;

			bookL[i] = bname;
			writerL[i] = bwriter;
		}
		return(bookL, writerL);
	}

	function userInformation(address user) constant returns(bytes32,bytes32[],uint[],uint[]){
		bytes32 userName = userInfo[user].name;
		var (cBook, bookrentDay,bookDue) = getCurrentBook(user);
		return (userName,cBook,bookrentDay,bookDue);
	}

	function userRentedBooks(address user) constant returns(bytes32[],uint[],uint[]){
		bytes32[] memory bookNames = new bytes32[](userInfo[user].rentedBooks.length);
		uint[] memory daysRentedStart = new uint[](userInfo[user].rentedBooks.length);
		uint[] memory daysRentedEnd = new uint[](userInfo[user].rentedBooks.length);
		for(uint i=0;i<userInfo[user].rentedBooks.length;i++){
			bytes32 bookName = userInfo[user].rentedBooks[i].name;
			uint daysRentStart = userInfo[user].rentedBooks[i].rentedDay;
			uint daysRentEnd = userInfo[user].rentedBooks[i].returnedDay;

			bookNames[i] = bookName;
			daysRentedStart[i] = daysRentStart;
			daysRentedEnd[i] = daysRentEnd;
		}
		return(bookNames,daysRentedStart,daysRentedEnd);
	}

	function checkBookExists(bytes32 bookName) internal constant returns(bool){
		if(bookInfo[bookName].name == bookName){
			return true;
		}
		else{
			return false;
		}
	}

	function checkUserExists(address user) internal constant returns(bool){
		if(userInfo[user].name == ""){
			return false;
		}
		else{
			return true;
		}
	}

	function addBook(bytes32 bookName,bytes32 bookWriter){
		bookList.push(bookName);
		bookInfo[bookName].name = bookName;
		bookInfo[bookName].writer = bookWriter;
	}

	function addUser(address user, bytes32 userName) {
		userList.push(userName);
		userInfo[user].name = userName;
	}

	function rentBook(address user, bytes32 bookName, uint8 dayRent, uint8 monthRent, uint16 yearRent, uint8 dayReturn,uint8 monthReturn, uint16 yearReturn){
		if (checkBookExists(bookName) == false || checkUserExists(user) == false) throw;
		if (bookInfo[bookName].currentRenter != 0x0000000000000000000000000000000000000000) throw;
		if (userInfo[user].currentBooks >= 5) throw;

		uint rentD = datetime.toTimestamp(yearRent,monthRent,dayRent);
		uint retD = datetime.toTimestamp(yearReturn,monthReturn,dayReturn);
		bookInfo[bookName].currentRenter = user;
		bookInfo[bookName].rentDate = rentD;
		bookInfo[bookName].returnDate = retD;
		bookInfo[bookName].timesRented += 1;
		userInfo[user].rentedBookInfo[bookName].name = bookName;
		userInfo[user].rentedBookInfo[bookName].rentedDay = rentD;
		userInfo[user].currentBooks += 1;
	}

	function returnBook(address user, bytes32 bookName, uint8 dayReturn,uint8 monthReturn, uint16 yearReturn){
		if (checkBookExists(bookName) == false || checkUserExists(user) == false) throw;
		if (bookInfo[bookName].currentRenter == 0x0000000000000000000000000000000000000000 || bookInfo[bookName].currentRenter != user) throw;

		userInfo[user].rentedBookInfo[bookName].rentedDay = bookInfo[bookName].rentDate;
		userInfo[user].rentedBookInfo[bookName].returnedDay = datetime.toTimestamp(yearReturn,monthReturn,dayReturn);
		bookInfo[bookName].rentDate = 0;
		bookInfo[bookName].returnDate = 0;
		bookInfo[bookName].currentRenter = 0x0000000000000000000000000000000000000000;
		userInfo[user].currentBooks -= 1;
	}

	function addReview(address user, bytes32 bookName,uint starsGiven, bytes32 reviewText){
		if (checkBookExists(bookName) == false || checkUserExists(user) == false) throw;

		bookInfo[bookName].reviewInfo[user].user = user;
		bookInfo[bookName].reviewInfo[user].stars = starsGiven;
		bookInfo[bookName].reviewInfo[user].review = reviewText;
	}
}