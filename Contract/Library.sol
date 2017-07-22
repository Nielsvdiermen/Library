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
			bytes32 bookName;
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
	}

	struct rentedBook{
			bytes32 bookName;
			address user;
			uint rentedDay;
			uint returnedDay;
		}

	struct User{
		bytes32 name;
		uint8 currentBooks;
	}

	bytes32[] bookList;
	bytes32[] userList;
	uint reviewAmount;
	uint bookRentals;

	mapping (bytes32 => book) bookInfo;
	mapping (address => User) userInfo;
	mapping (uint => review) reviewInfo;
	mapping (uint => rentedBook) rentedInfo;

	function getCurrentBooks(address user) internal constant returns(bytes32[],uint[],uint[]){
	  bytes32[] memory bookNameArray = new bytes32[](5);
		uint[] memory rentArray = new uint[](5);
		uint[] memory returnArray = new uint[](5);
		
		for(uint i=0;i<bookList.length;i++){
			if(bookInfo[bookList[i]].currentRenter == user){
				for (uint j=0;j<5;j++){
					if(bookNameArray[j] == ""){
						bookNameArray[j] = bookList[i];
						rentArray[j] = bookInfo[bookList[i]].rentDate;
						returnArray[j] = bookInfo[bookList[i]].returnDate;
						j = 5;
					}
				}
			}
		}

		return (bookNameArray,rentArray,returnArray);
	}

	function bookInformation(bytes32 bookName) constant returns(bytes32,bytes32,uint[],uint[]){
		if(bookInfo[bookName].name == "")throw;
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

	function getBookReviews(bytes32 bookName) constant returns(uint[],bytes32[],address[]){
		uint reviewsBookAmount;
		uint reviewIterator = 0;

		for(uint j=0;j<reviewAmount;j++){
			if(reviewInfo[j].bookName == bookName){
				reviewsBookAmount += 1;
			}
		}

		uint[] memory stars = new uint[](reviewsBookAmount);
		bytes32[] memory reviews = new bytes32[](reviewsBookAmount);
		address[] memory users = new address[](reviewsBookAmount);

		for(uint i=0;i<reviewAmount;i++){
			if(reviewInfo[i].bookName == bookName){
				users[reviewIterator] = reviewInfo[i].user;
				stars[reviewIterator] = reviewInfo[i].stars;
				reviews[reviewIterator] = reviewInfo[i].review;
				reviewIterator += 1;
			}
		}
		return(stars,reviews,users);
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
		var (cBook, bookrentDay,bookDue) = getCurrentBooks(user);
		return (userName,cBook,bookrentDay,bookDue);
	}

	function userRentedBooks(address user) constant returns(bytes32[],uint[],uint[]){
		uint bookRentalsAmount;
		uint rentalIterator = 0;

		for(uint j=0;j<bookRentals;j++){
			if(rentedInfo[j].user == user){
				bookRentalsAmount += 1;
			}
		}

		bytes32[] memory bookNames = new bytes32[](bookRentalsAmount);
		uint[] memory daysRentedStart = new uint[](bookRentalsAmount);
		uint[] memory daysRentedEnd = new uint[](bookRentalsAmount);

		for(uint i=0;i<bookRentals;i++){
			if(rentedInfo[rentalIterator].user == user){
				bookNames[rentalIterator] = rentedInfo[i].bookName;
				daysRentedStart[rentalIterator] = rentedInfo[i].rentedDay;
				daysRentedEnd[rentalIterator] = rentedInfo[i].returnedDay;

				rentalIterator += 1;
			}
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
		if(bookName == "" || bookWriter == "") throw;
		bookList.push(bookName);
		bookInfo[bookName].name = bookName;
		bookInfo[bookName].writer = bookWriter;
	}

	function addUser(address user, bytes32 userName) {
		if(userName == "") throw;
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
		userInfo[user].currentBooks += 1;
	}

	function returnBook(address user, bytes32 bookName, uint8 dayReturn,uint8 monthReturn, uint16 yearReturn){
		if (checkBookExists(bookName) == false || checkUserExists(user) == false) throw;
		if (bookInfo[bookName].currentRenter == 0x0000000000000000000000000000000000000000 || bookInfo[bookName].currentRenter != user) throw;
		rentedInfo[bookRentals].bookName = bookName;
		rentedInfo[bookRentals].user = user;
		rentedInfo[bookRentals].rentedDay = bookInfo[bookName].rentDate;
		rentedInfo[bookRentals].returnedDay = datetime.toTimestamp(yearReturn,monthReturn,dayReturn);
		bookRentals += 1;

		bookInfo[bookName].rentDate = 0;
		bookInfo[bookName].returnDate = 0;
		bookInfo[bookName].currentRenter = 0x0000000000000000000000000000000000000000;
		userInfo[user].currentBooks -= 1;
	}

	function addReview(address user, bytes32 bookName,uint starsGiven, bytes32 reviewText){
		if (checkBookExists(bookName) == false || checkUserExists(user) == false) throw;
		reviewInfo[reviewAmount].bookName = bookName;
		reviewInfo[reviewAmount].user = user;
		reviewInfo[reviewAmount].stars = starsGiven;
		reviewInfo[reviewAmount].review = reviewText;
		reviewAmount += 1;
	}
}