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
	}

	struct rentedBook{
			bytes32 name;
			uint rentedDay;
			uint returnedDay;
		}

	struct User{
		bytes32 name;
		rentedBook[] rentedBooks;
	}

	bytes32[] bookList;

	mapping (bytes32 => book) public bookInfo;
	mapping (address => User) public userInfo;
	mapping (bytes32 => rentedBook) public rentedBookInfo;
	mapping (address => review) public reviewInfo;

	function getCurrentBook(address user) constant returns(bytes32,uint[],uint[]){
		uint[] rentArray;
		uint[] returnArray;

		for(uint i=0;i<bookList.length;i++){
			if(bookInfo[bookList[i]].currentRenter == user){
				rentArray.push(datetime.getDay(bookInfo[bookList[i]].rentDate));
				rentArray.push(datetime.getMonth(bookInfo[bookList[i]].rentDate));
				rentArray.push(datetime.getYear(bookInfo[bookList[i]].rentDate));
				returnArray.push(datetime.getDay(bookInfo[bookList[i]].returnDate));
				returnArray.push(datetime.getMonth(bookInfo[bookList[i]].returnDate));
				returnArray.push(datetime.getYear(bookInfo[bookList[i]].returnDate));
				return (bookList[i],rentArray,returnArray);
			}
		}

		return ("no book",rentArray,returnArray);
	}

	function bookInformation(bytes32 bookName) constant returns(bytes32, uint[],bytes32[],bytes32,uint[],uint[],uint){
		bytes32 writer = bookInfo[bookName].writer;
		uint[] stars;
		bytes32[] reviews;
		for(uint i=0;i<bookInfo[bookName].reviews.length;i++){
			uint star = bookInfo[bookName].reviews[i].stars;
			bytes32 review = bookInfo[bookName].reviews[i].review;
			stars[i] = star;
			reviews[i] = review;
		}
		bytes32 currentRent = userInfo[bookInfo[bookName].currentRenter].name;

		uint[] rentArray;
		rentArray.push(datetime.getDay(bookInfo[bookName].rentDate));
		rentArray.push(datetime.getMonth(bookInfo[bookName].rentDate));
		rentArray.push(datetime.getYear(bookInfo[bookName].rentDate));

		uint[] returnArray;
		returnArray.push(datetime.getDay(bookInfo[bookName].returnDate));
		returnArray.push(datetime.getMonth(bookInfo[bookName].returnDate));
		returnArray.push(datetime.getYear(bookInfo[bookName].returnDate));

		uint rentTimes = bookInfo[bookName].timesRented;

		return (writer,stars,reviews,currentRent,rentArray,returnArray,rentTimes);
	}

	function userInformation(address user) constant returns(bytes32, bytes32[],uint[],uint[],bytes32,uint[],uint[]){
		bytes32 userName = userInfo[user].name;
		bytes32[] bookNames;
		uint[] daysRentedStart;
		uint[] daysRentedEnd;
		for(uint i=0;i<userInfo[user].rentedBooks.length;i++){
			bytes32 bookName = userInfo[user].rentedBooks[i].name;
			uint daysRentStart = userInfo[user].rentedBooks[i].rentedDay;
			uint daysRentEnd = userInfo[user].rentedBooks[i].returnedDay;

			bookNames[i] = bookName;
			daysRentedStart[i] = daysRentStart;
		}
		var (cBook, bookrentDay,bookDue) = getCurrentBook(user);
		return (userName,bookNames,daysRentedStart,daysRentedEnd,cBook,bookrentDay,bookDue);
	}

	function addBook(bytes32 bookName,bytes32 bookWriter){
		bookList.push(bookName);
		bookInfo[bookName].name = bookName;
		bookInfo[bookName].writer = bookWriter;
	}

	function rentBook(address user, bytes32 bookName, uint8 dayRent, uint8 monthRent, uint8 yearRent, uint8 dayReturn,uint8 monthReturn, uint8 yearReturn){
		uint rentD = datetime.toTimestamp(yearRent,monthRent,dayRent);
		uint retD = datetime.toTimestamp(yearReturn,monthReturn,dayReturn);
		bookInfo[bookName].currentRenter = user;
		bookInfo[bookName].rentDate = rentD;
		bookInfo[bookName].returnDate = retD;
		bookInfo[bookName].timesRented += 1;
		userInfo[user].rentedBookInfo[bookName].name = bookName;
	}

	function returnBook(address user, bytes32 bookName, uint8 dayReturn,uint8 monthReturn, uint8 yearReturn){
		userInfo[user].rentedBooks[bookName].rentedDay = bookInfo[bookName].rentDate;
		userInfo[user].rentedBooks[bookName].returnedDay = datetime.toTimestamp(yearReturn,monthReturn,dayReturn);
		bookInfo[bookName].rentDate = 0;
		bookInfo[bookName].returnDate = 0;
		bookInfo[bookName].currentRenter = 0x0000000000000000000000000000000000000000;
	}

	function addReview(address user, bytes32 bookName,uint starsGiven, bytes32 reviewText){
		bookInfo[bookName].reviewInfo[user].user = user;
		bookInfo[bookName].reviewInfo[user].stars = starsGiven;
		bookInfo[bookName].reviewInfo[user].review = reviewText;
	}
}