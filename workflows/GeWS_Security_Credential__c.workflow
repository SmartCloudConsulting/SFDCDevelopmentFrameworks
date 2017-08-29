<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_UID</fullName>
        <description>Updates the UID on the Security Credential Record</description>
        <field>GeWS_EnterpriseUniqueId__c</field>
        <formula>GeWS_EnterpriseUniqueIdSeq__c</formula>
        <name>Update UID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate Security Credential</fullName>
        <actions>
            <name>Update_UID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>GeWS_Security_Credential__c.GeWS_EnterpriseUniqueId__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the Security Credential Enterprise Unique ID</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
