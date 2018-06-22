pragma solidity ^0.4.19;

import "@digix/cacp-contracts-dao/contracts/ResolverClient.sol";
import "../common/DaoConstants.sol";
import "../lib/DaoStructs.sol";

// this contract will receive DGXs fees from the DGX fees distributors
contract DaoRewardsStorage is ResolverClient, DaoConstants {
    using DaoStructs for DaoStructs.DaoQuarterInfo;

    mapping(uint256 => DaoStructs.DaoQuarterInfo) public allQuartersInfo;
    mapping(address => uint256) public claimableDGXs;
    uint256 public totalDGXsClaimed;

    mapping (address => uint256) public lastParticipatedQuarter;
    mapping (address => uint256) public lastQuarterThatRewardsWasUpdated;
    mapping (address => uint256) public lastQuarterThatReputationWasUpdated;

    function DaoRewardsStorage(address _resolver)
           public
    {
        require(init(CONTRACT_STORAGE_DAO_REWARDS, _resolver));
    }

    function updateQuarterInfo(
        uint256 _quarterIndex,
        uint256 _minimalParticipationPoint,
        uint256 _quarterPointScalingFactor,
        uint256 _reputationPointScalingFactor,
        uint256 _totalEffectiveDGDLastQuarter,

        uint256 _badgeMinimalParticipationPoint,
        uint256 _badgeQuarterPointScalingFactor,
        uint256 _badgeReputationPointScalingFactor,
        uint256 _totalEffectiveBadgeLastQuarter,

        uint256 _dgxDistributionDay,
        uint256 _dgxRewardsPoolLastQuarter,
        uint256 _sumRewardsFromBeginning
    )
        if_sender_is(CONTRACT_DAO_REWARDS_MANAGER)
        public
    {
        allQuartersInfo[_quarterIndex].minimalParticipationPoint = _minimalParticipationPoint;
        allQuartersInfo[_quarterIndex].quarterPointScalingFactor = _quarterPointScalingFactor;
        allQuartersInfo[_quarterIndex].reputationPointScalingFactor = _reputationPointScalingFactor;
        allQuartersInfo[_quarterIndex].totalEffectiveDGDLastQuarter = _totalEffectiveDGDLastQuarter;

        allQuartersInfo[_quarterIndex].badgeMinimalParticipationPoint = _badgeMinimalParticipationPoint;
        allQuartersInfo[_quarterIndex].badgeQuarterPointScalingFactor = _badgeQuarterPointScalingFactor;
        allQuartersInfo[_quarterIndex].badgeReputationPointScalingFactor = _badgeReputationPointScalingFactor;
        allQuartersInfo[_quarterIndex].totalEffectiveBadgeLastQuarter = _totalEffectiveBadgeLastQuarter;

        allQuartersInfo[_quarterIndex].dgxDistributionDay = _dgxDistributionDay;
        allQuartersInfo[_quarterIndex].dgxRewardsPoolLastQuarter = _dgxRewardsPoolLastQuarter;
        allQuartersInfo[_quarterIndex].sumRewardsFromBeginning = _sumRewardsFromBeginning;
    }

    function updateReputationPointAtQuarter(
        address _user,
        uint256 _quarterIndex,
        uint256 _reputationPoint
    )
        if_sender_is(CONTRACT_DAO_REWARDS_MANAGER)
        public
    {
        allQuartersInfo[_quarterIndex].reputationPoint[_user] = _reputationPoint;
    }

    function updateClaimableDGX(address _user, uint256 _newClaimableDGX)
        if_sender_is(CONTRACT_DAO_REWARDS_MANAGER)
        public
    {
        claimableDGXs[_user] = _newClaimableDGX;
    }

    function updateLastParticipatedQuarter(address _user, uint256 _lastQuarter)
        if_sender_is(CONTRACT_DAO_STAKE_LOCKING)
        public
    {
        lastParticipatedQuarter[_user] = _lastQuarter;
    }

    function updateLastQuarterThatRewardsWasUpdated(address _user, uint256 _lastQuarter)
        if_sender_is(CONTRACT_DAO_REWARDS_MANAGER)
        public
    {
        lastQuarterThatRewardsWasUpdated[_user] = _lastQuarter;
    }

    function updateLastQuarterThatReputationWasUpdated(address _user, uint256 _lastQuarter)
        if_sender_is(CONTRACT_DAO_REWARDS_MANAGER)
        public
    {
        lastQuarterThatReputationWasUpdated[_user] = _lastQuarter;
    }

    function addToTotalDgxClaimed(uint256 _dgxClaimed)
        if_sender_is(CONTRACT_DAO_REWARDS_MANAGER)
        public
    {
        totalDGXsClaimed += _dgxClaimed;
    }

    function readQuarterInfo(uint256 _quarterIndex)
        public
        constant
        returns (
            uint256 _minimalParticipationPoint,
            uint256 _quarterPointScalingFactor,
            uint256 _reputationPointScalingFactor,
            uint256 _totalEffectiveDGDLastQuarter,

            uint256 _badgeMinimalParticipationPoint,
            uint256 _badgeQuarterPointScalingFactor,
            uint256 _badgeReputationPointScalingFactor,
            uint256 _totalEffectiveBadgeLastQuarter,

            uint256 _dgxDistributionDay,
            uint256 _dgxRewardsPoolLastQuarter,
            uint256 _sumRewardsFromBeginning
        )
    {
        _minimalParticipationPoint = allQuartersInfo[_quarterIndex].minimalParticipationPoint;
        _quarterPointScalingFactor = allQuartersInfo[_quarterIndex].quarterPointScalingFactor;
        _reputationPointScalingFactor = allQuartersInfo[_quarterIndex].reputationPointScalingFactor;
        _totalEffectiveDGDLastQuarter = allQuartersInfo[_quarterIndex].totalEffectiveDGDLastQuarter;
        _badgeMinimalParticipationPoint = allQuartersInfo[_quarterIndex].badgeMinimalParticipationPoint;
        _badgeQuarterPointScalingFactor = allQuartersInfo[_quarterIndex].badgeQuarterPointScalingFactor;
        _badgeReputationPointScalingFactor = allQuartersInfo[_quarterIndex].badgeReputationPointScalingFactor;
        _totalEffectiveBadgeLastQuarter = allQuartersInfo[_quarterIndex].totalEffectiveBadgeLastQuarter;
        _dgxDistributionDay = allQuartersInfo[_quarterIndex].dgxDistributionDay;
        _dgxRewardsPoolLastQuarter = allQuartersInfo[_quarterIndex].dgxRewardsPoolLastQuarter;
        _sumRewardsFromBeginning = allQuartersInfo[_quarterIndex].sumRewardsFromBeginning;
    }

    function readQuarterGeneralInfo(uint256 _quarterIndex)
        public
        constant
        returns (
            uint256 _dgxDistributionDay,
            uint256 _dgxRewardsPoolLastQuarter,
            uint256 _sumRewardsFromBeginning
        )
    {
        _dgxDistributionDay = allQuartersInfo[_quarterIndex].dgxDistributionDay;
        _dgxRewardsPoolLastQuarter = allQuartersInfo[_quarterIndex].dgxRewardsPoolLastQuarter;
        _sumRewardsFromBeginning = allQuartersInfo[_quarterIndex].sumRewardsFromBeginning;
    }

    function readQuarterBadgeParticipantInfo(uint256 _quarterIndex)
        public
        constant
        returns (
            uint256 _badgeMinimalParticipationPoint,
            uint256 _badgeQuarterPointScalingFactor,
            uint256 _badgeReputationPointScalingFactor,
            uint256 _totalEffectiveBadgeLastQuarter
        )
    {
        _badgeMinimalParticipationPoint = allQuartersInfo[_quarterIndex].badgeMinimalParticipationPoint;
        _badgeQuarterPointScalingFactor = allQuartersInfo[_quarterIndex].badgeQuarterPointScalingFactor;
        _badgeReputationPointScalingFactor = allQuartersInfo[_quarterIndex].badgeReputationPointScalingFactor;
        _totalEffectiveBadgeLastQuarter = allQuartersInfo[_quarterIndex].totalEffectiveBadgeLastQuarter;
    }

    function readQuarterParticipantInfo(uint256 _quarterIndex)
        public
        constant
        returns (
            uint256 _minimalParticipationPoint,
            uint256 _quarterPointScalingFactor,
            uint256 _reputationPointScalingFactor,
            uint256 _totalEffectiveDGDLastQuarter
        )
    {
        _minimalParticipationPoint = allQuartersInfo[_quarterIndex].minimalParticipationPoint;
        _quarterPointScalingFactor = allQuartersInfo[_quarterIndex].quarterPointScalingFactor;
        _reputationPointScalingFactor = allQuartersInfo[_quarterIndex].reputationPointScalingFactor;
        _totalEffectiveDGDLastQuarter = allQuartersInfo[_quarterIndex].totalEffectiveDGDLastQuarter;
    }

    function readDgxDistributionDay(uint256 _quarterIndex)
        public
        view
        returns (uint256 _distributionDay)
    {
        _distributionDay = allQuartersInfo[_quarterIndex].dgxDistributionDay;
    }

    function readTotalEffectiveDGDLastQuarter(uint256 _quarterIndex)
        public
        view
        returns (uint256 _totalEffectiveDGDLastQuarter)
    {
        _totalEffectiveDGDLastQuarter = allQuartersInfo[_quarterIndex].totalEffectiveDGDLastQuarter;
    }

    function readTotalEffectiveBadgeLastQuarter(uint256 _quarterIndex)
        public
        view
        returns (uint256 _totalEffectiveBadgeLastQuarter)
    {
        _totalEffectiveBadgeLastQuarter = allQuartersInfo[_quarterIndex].totalEffectiveBadgeLastQuarter;
    }

    function readRewardsPoolOfLastQuarter(uint256 _quarterIndex)
        public
        view
        returns (uint256 _rewardsPool)
    {
        _rewardsPool = allQuartersInfo[_quarterIndex].dgxRewardsPoolLastQuarter;
    }

    function readReputationPointAtQuarter(address _user, uint256 _quarterIndex)
        public
        constant
        returns (uint256 _reputationPoint)
    {
        _reputationPoint = allQuartersInfo[_quarterIndex].reputationPoint[_user];
    }

}