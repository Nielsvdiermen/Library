pragma solidity ^0.4.11;

import "./datetime.sol" as datetimeContract;
import "./datetimeAPI.sol" as datetimeAPI;

contract BookLibrary { 

	datetimeAPI datetime = datetimeAPI(datetimeContract);

	struct review{
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
			uint daysRented; 
		}

	struct User{
		bytes32 name;
		rentedBook[] rentedBooks;
	}

	bytes32[] bookList;

	mapping (bytes32 => book) public bookInfo;
	mapping (address => User) public userInfo;
	mapping (bytes32 => rentedBook) public rentedBookInfo;

	function getCurrentBook(address user) constant returns(bytes32,bytes32,bytes32){
		for(uint i=0;i<bookList.length;i++){
			if(bookInfo[bookList[i]].currentRenter == user){
				bytes32 rentDay = datetime.getDay(bookInfo[bookList[i]].rentDate).tostring() + "-" + datetime.getMonth(bookInfo[bookList[i]].rentDate).tostring() + "-" + datetime.getYear(bookInfo[bookList[i]].rentDate).tostring();
				bytes32 returnDay = datetime.getDay(bookInfo[bookList[i]].returnDate).tostring() + "-" + datetime.getMonth(bookInfo[bookList[i]].returnDate).tostring() + "-" + datetime.getYear(bookInfo[bookList[i]].returnDate).tostring();
				return (bookList[i],rentDay,returnDay);
			}
		}
		return ("no book","","");
	}

	function bookInformation(bytes32 name) constant returns(bytes32, uint[],bytes32[],bytes32,bytes32,bytes32,uint){
		bytes32 writer = bookInfo[name].writer;
		uint[] stars;
		bytes32[] reviews;
		for(uint i=0;i<bookInfo[name].reviews.length;i++){
			uint star = bookInfo[name].reviews[i].stars;
			bytes32 review = bookInfo[name].reviews[i].review;
			stars[i] = star;
			reviews[i] = review;
		}
		bytes32 currentRent = User[address];
		bytes32 rentDay = datetime.getDay(bookInfo[name].rentDate).tostring() + "-" + datetime.getMonth(bookInfo[name].rentDate).tostring() + "-" + datetime.getYear(bookInfo[name].rentDate).tostring();
		bytes32 returnDay = datetime.getDay(bookInfo[name].returnDate).tostring() + "-" + datetime.getMonth(bookInfo[name].returnDate).tostring() + "-" + datetime.getYear(bookInfo[name].returnDa).tostring();
		uint rentTimes = bookInfo[name].timesRented;

		return (writer,stars, reviews, currentRent,rentDay,returnDay,rentTimes);
	}

	function userInformation(address user) constant returns(bytes32, bytes32[],uint[],bytes32,bytes32,bytes32){
		bytes32 userName = User[user].name;
		bytes32[] bookNames;
		uint[] daysRented;
		for(uint i=0;i<User[user].rentedBooks.length;i++){
			bytes32 bookName = User[user].rentedBooks[i].name;
			uint daysRent = User[user].rentedBooks[i].daysRented;
			bookNames[i] = bookName;
			daysRented[i] = daysRent;
		}
		bytes32 cBook = getCurrentBook(user)[0];
		bytes32 bookrentDay = getCurrentBook(user)[1];
		bytes32 bookDue = getCurrentBook(user)[2];
		return (userName,bookNames,daysRented,cBook,bookrentDay,bookDue);
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

	function returnBook(address user, bytes32 bookName, uint8 returnDay, uint8 returnMonth, uint8 returnYear){
		
	}
}