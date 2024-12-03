// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BettingSubscription {
    address public owner;

    // Subscription plans
    struct Plan {
        string name;
        uint256 price; // Price in wei
        uint256 duration; // Duration in seconds
    }

    Plan[] public plans;

    // Subscription info
    struct Subscription {
        uint256 planId;
        uint256 expiry;
    }

    mapping(address => Subscription) public subscriptions;

    // Events
    event PlanCreated(uint256 indexed planId, string name, uint256 price, uint256 duration);
    event Subscribed(address indexed user, uint256 indexed planId, uint256 expiry);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    // Constructor: Set the owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Add a new subscription plan
    function createPlan(string memory name, uint256 price, uint256 duration) external onlyOwner {
        require(price > 0, "Price must be greater than zero");
        require(duration > 0, "Duration must be greater than zero");
        
        plans.push(Plan(name, price, duration));
        emit PlanCreated(plans.length - 1, name, price, duration);
    }

    // Subscribe to a plan
    function subscribe(uint256 planId) external payable {
        require(planId < plans.length, "Invalid plan");
        Plan memory plan = plans[planId];
        require(msg.value >= plan.price, "Insufficient payment");

        // Update or create a subscription
        if (subscriptions[msg.sender].expiry > block.timestamp) {
            // Extend existing subscription
            subscriptions[msg.sender].expiry += plan.duration;
        } else {
            // Start new subscription
            subscriptions[msg.sender] = Subscription(planId, block.timestamp + plan.duration);
        }

        emit Subscribed(msg.sender, planId, subscriptions[msg.sender].expiry);
    }

    // Check if a user is subscribed
    function isSubscribed(address user) public view returns (bool) {
        return subscriptions[user].expiry > block.timestamp;
    }

    // Withdraw funds
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner).transfer(balance);
        emit FundsWithdrawn(owner, balance);
    }

    // View plan details
    function getPlan(uint256 planId) public view returns (string memory, uint256, uint256) {
        require(planId < plans.length, "Invalid plan");
        Plan memory plan = plans[planId];
        return (plan.name, plan.price, plan.duration);
    }
}
