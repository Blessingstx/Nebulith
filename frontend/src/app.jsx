import React, { useState } from 'react';
import { Vote, Users, TrendingUp, Clock, CheckCircle, XCircle, AlertCircle, Wallet, FileText, DollarSign } from 'lucide-react';

export default function NebulithDAO() {
  const [activeTab, setActiveTab] = useState('proposals');
  const [proposals, setProposals] = useState([
    {
      id: 1,
      title: 'Increase Marketing Budget',
      description: 'Allocate additional 500K tokens for Q2 marketing initiatives to expand community reach',
      proposer: 'SP2ZRX...ABC123',
      type: 'treasury',
      amount: 500000,
      recipient: 'SP1ABC...XYZ789',
      state: 'Active',
      forVotes: 2500000,
      againstVotes: 500000,
      abstainVotes: 100000,
      startBlock: 12450,
      endBlock: 13458,
      currentBlock: 12800,
      requiresMultisig: false,
      createdAt: '2025-01-15'
    },
    {
      id: 2,
      title: 'Update Governance Parameters',
      description: 'Reduce voting delay from 144 blocks to 72 blocks to improve proposal responsiveness',
      proposer: 'SP1XYZ...DEF456',
      type: 'parameter',
      state: 'Awaiting Signatures',
      forVotes: 15000000,
      againstVotes: 2000000,
      abstainVotes: 500000,
      startBlock: 11000,
      endBlock: 12008,
      currentBlock: 12800,
      requiresMultisig: true,
      signatures: 1,
      requiredSignatures: 2,
      createdAt: '2025-01-10'
    },
    {
      id: 3,
      title: 'Community Development Fund',
      description: 'Establish dedicated fund for community-driven development projects',
      proposer: 'SP3ABC...GHI789',
      type: 'general',
      state: 'Pending',
      forVotes: 0,
      againstVotes: 0,
      abstainVotes: 0,
      startBlock: 13000,
      endBlock: 14008,
      currentBlock: 12800,
      requiresMultisig: false,
      createdAt: '2025-01-16'
    }
  ]);

  const [userStats, setUserStats] = useState({
    votingPower: 150000,
    delegatedPower: 50000,
    activeProposals: 2,
    maxQueueSize: 10,
    address: 'SP1ABC...XYZ789'
  });

  const getStateColor = (state) => {
    const colors = {
      'Active': 'bg-blue-100 text-blue-800',
      'Pending': 'bg-yellow-100 text-yellow-800',
      'Succeeded': 'bg-green-100 text-green-800',
      'Defeated': 'bg-red-100 text-red-800',
      'Executed': 'bg-purple-100 text-purple-800',
      'Awaiting Signatures': 'bg-orange-100 text-orange-800',
      'Cancelled': 'bg-gray-100 text-gray-800'
    };
    return colors[state] || 'bg-gray-100 text-gray-800';
  };

  const getStateIcon = (state) => {
    switch(state) {
      case 'Active': return <Vote className="w-4 h-4" />;
      case 'Succeeded': return <CheckCircle className="w-4 h-4" />;
      case 'Defeated': return <XCircle className="w-4 h-4" />;
      case 'Awaiting Signatures': return <Clock className="w-4 h-4" />;
      default: return <AlertCircle className="w-4 h-4" />;
    }
  };

  const getTypeIcon = (type) => {
    switch(type) {
      case 'treasury': return <DollarSign className="w-4 h-4" />;
      case 'parameter': return <TrendingUp className="w-4 h-4" />;
      default: return <FileText className="w-4 h-4" />;
    }
  };

  const calculateProgress = (proposal) => {
    const total = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
    const forPercentage = total > 0 ? (proposal.forVotes / total) * 100 : 0;
    const againstPercentage = total > 0 ? (proposal.againstVotes / total) * 100 : 0;
    return { forPercentage, againstPercentage, total };
  };

  const calculateTimeRemaining = (proposal) => {
    if (proposal.state !== 'Active') return null;
    const remaining = proposal.endBlock - proposal.currentBlock;
    const days = Math.floor(remaining / 144);
    const hours = Math.floor((remaining % 144) / 6);
    return `${days}d ${hours}h remaining`;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-lg flex items-center justify-center">
                <Vote className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Nebulith DAO</h1>
                <p className="text-xs text-gray-500">Decentralized Governance</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              <div className="hidden md:flex items-center space-x-2 bg-indigo-50 px-4 py-2 rounded-lg">
                <Wallet className="w-4 h-4 text-indigo-600" />
                <span className="text-sm font-medium text-indigo-900">{userStats.votingPower.toLocaleString()} VP</span>
              </div>
              <button className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                Connect Wallet
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Stats Bar */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="bg-gradient-to-br from-blue-50 to-blue-100 p-4 rounded-lg border border-blue-200">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-blue-600 font-medium">Your Voting Power</p>
                  <p className="text-2xl font-bold text-blue-900">{userStats.votingPower.toLocaleString()}</p>
                </div>
                <Vote className="w-8 h-8 text-blue-400" />
              </div>
            </div>
            
            <div className="bg-gradient-to-br from-purple-50 to-purple-100 p-4 rounded-lg border border-purple-200">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-purple-600 font-medium">Delegated To You</p>
                  <p className="text-2xl font-bold text-purple-900">{userStats.delegatedPower.toLocaleString()}</p>
                </div>
                <Users className="w-8 h-8 text-purple-400" />
              </div>
            </div>
            
            <div className="bg-gradient-to-br from-green-50 to-green-100 p-4 rounded-lg border border-green-200">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-green-600 font-medium">Your Active Proposals</p>
                  <p className="text-2xl font-bold text-green-900">{userStats.activeProposals}/{userStats.maxQueueSize}</p>
                </div>
                <FileText className="w-8 h-8 text-green-400" />
              </div>
            </div>
            
            <div className="bg-gradient-to-br from-orange-50 to-orange-100 p-4 rounded-lg border border-orange-200">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-orange-600 font-medium">Total Proposals</p>
                  <p className="text-2xl font-bold text-orange-900">{proposals.length}</p>
                </div>
                <TrendingUp className="w-8 h-8 text-orange-400" />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Tabs */}
        <div className="mb-6 border-b border-gray-200">
          <nav className="flex space-x-8">
            {['proposals', 'create', 'delegate'].map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`pb-4 px-1 border-b-2 font-medium text-sm capitalize transition-colors ${
                  activeTab === tab
                    ? 'border-indigo-500 text-indigo-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab}
              </button>
            ))}
          </nav>
        </div>

        {/* Proposals Tab */}
        {activeTab === 'proposals' && (
          <div className="space-y-4">
            {proposals.map((proposal) => {
              const { forPercentage, againstPercentage, total } = calculateProgress(proposal);
              const timeRemaining = calculateTimeRemaining(proposal);
              
              return (
                <div key={proposal.id} className="bg-white rounded-xl border border-gray-200 overflow-hidden hover:shadow-lg transition-shadow">
                  <div className="p-6">
                    {/* Header */}
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex-1">
                        <div className="flex items-center space-x-2 mb-2">
                          <span className={`inline-flex items-center space-x-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${getStateColor(proposal.state)}`}>
                            {getStateIcon(proposal.state)}
                            <span>{proposal.state}</span>
                          </span>
                          <span className="inline-flex items-center space-x-1 px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-700 capitalize">
                            {getTypeIcon(proposal.type)}
                            <span>{proposal.type}</span>
                          </span>
                          {proposal.requiresMultisig && (
                            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800">
                              Requires Multisig
                            </span>
                          )}
                        </div>
                        <h3 className="text-lg font-semibold text-gray-900 mb-1">
                          #{proposal.id} {proposal.title}
                        </h3>
                        <p className="text-sm text-gray-600 mb-2">{proposal.description}</p>
                        <div className="flex items-center space-x-4 text-xs text-gray-500">
                          <span>Proposer: {proposal.proposer}</span>
                          <span>•</span>
                          <span>Created: {proposal.createdAt}</span>
                          {timeRemaining && (
                            <>
                              <span>•</span>
                              <span className="text-indigo-600 font-medium">{timeRemaining}</span>
                            </>
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Treasury Info */}
                    {proposal.type === 'treasury' && (
                      <div className="bg-green-50 border border-green-200 rounded-lg p-3 mb-4">
                        <div className="flex items-center justify-between text-sm">
                          <span className="text-green-700 font-medium">Treasury Transfer:</span>
                          <span className="text-green-900 font-bold">{proposal.amount.toLocaleString()} tokens → {proposal.recipient}</span>
                        </div>
                      </div>
                    )}

                    {/* Voting Progress */}
                    {total > 0 && (
                      <div className="mb-4">
                        <div className="flex items-center justify-between text-sm mb-2">
                          <span className="text-gray-700 font-medium">Voting Progress</span>
                          <span className="text-gray-500">{total.toLocaleString()} votes</span>
                        </div>
                        <div className="flex h-3 bg-gray-100 rounded-full overflow-hidden">
                          <div
                            className="bg-gradient-to-r from-green-400 to-green-500"
                            style={{ width: `${forPercentage}%` }}
                          />
                          <div
                            className="bg-gradient-to-r from-red-400 to-red-500"
                            style={{ width: `${againstPercentage}%` }}
                          />
                        </div>
                        <div className="flex items-center justify-between mt-2 text-xs">
                          <span className="text-green-600 font-medium">
                            For: {forPercentage.toFixed(1)}% ({proposal.forVotes.toLocaleString()})
                          </span>
                          <span className="text-red-600 font-medium">
                            Against: {againstPercentage.toFixed(1)}% ({proposal.againstVotes.toLocaleString()})
                          </span>
                        </div>
                      </div>
                    )}

                    {/* Multisig Status */}
                    {proposal.requiresMultisig && proposal.state === 'Awaiting Signatures' && (
                      <div className="bg-amber-50 border border-amber-200 rounded-lg p-3 mb-4">
                        <div className="flex items-center justify-between text-sm">
                          <span className="text-amber-700 font-medium">Guardian Signatures:</span>
                          <span className="text-amber-900 font-bold">{proposal.signatures}/{proposal.requiredSignatures}</span>
                        </div>
                      </div>
                    )}

                    {/* Actions */}
                    <div className="flex items-center space-x-3">
                      {proposal.state === 'Active' && (
                        <>
                          <button className="flex-1 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                            Vote For
                          </button>
                          <button className="flex-1 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                            Vote Against
                          </button>
                          <button className="flex-1 bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                            Abstain
                          </button>
                        </>
                      )}
                      {proposal.state === 'Awaiting Signatures' && (
                        <button className="flex-1 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                          Sign as Guardian
                        </button>
                      )}
                      {proposal.state === 'Succeeded' && (
                        <button className="flex-1 bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                          Execute Proposal
                        </button>
                      )}
                      {(proposal.state === 'Pending' || proposal.state === 'Active') && (
                        <button className="bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                          Cancel
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {/* Create Tab */}
        {activeTab === 'create' && (
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-6">Create New Proposal</h2>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Proposal Type</label>
                <select className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent">
                  <option>General Proposal</option>
                  <option>Treasury Proposal</option>
                  <option>Parameter Change</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Title</label>
                <input
                  type="text"
                  placeholder="Enter proposal title (max 100 characters)"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  maxLength={100}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
                <textarea
                  rows={4}
                  placeholder="Enter detailed proposal description (max 500 characters)"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  maxLength={500}
                />
              </div>

              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <p className="text-sm text-blue-800">
                  <strong>Queue Status:</strong> You have {userStats.activeProposals} of {userStats.maxQueueSize} active proposals. 
                  Creating this proposal will use 1 queue slot.
                </p>
              </div>

              <button className="w-full bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-3 rounded-lg font-medium transition-colors">
                Create Proposal
              </button>
            </div>
          </div>
        )}

        {/* Delegate Tab */}
        {activeTab === 'delegate' && (
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-6">Delegate Voting Power</h2>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Delegate Address</label>
                <input
                  type="text"
                  placeholder="SP1ABC...XYZ789"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Amount to Delegate</label>
                <input
                  type="number"
                  placeholder="Enter amount"
                  max={userStats.votingPower}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
                <p className="text-xs text-gray-500 mt-1">Available: {userStats.votingPower.toLocaleString()} tokens</p>
              </div>

              <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
                <p className="text-sm text-amber-800">
                  <strong>Note:</strong> Delegated voting power cannot be used to vote yourself. You can revoke delegation at any time.
                </p>
              </div>

              <div className="flex space-x-3">
                <button className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-3 rounded-lg font-medium transition-colors">
                  Delegate
                </button>
                <button className="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 px-6 py-3 rounded-lg font-medium transition-colors">
                  Revoke Delegation
                </button>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="text-center text-sm text-gray-500">
            <p>Nebulith DAO v3.2 - Decentralized Governance with Queue Management</p>
            <p className="mt-1">Built on Stacks Blockchain | Empowering Communities</p>
          </div>
        </div>
      </footer>
    </div>
  );
}